function DWI_processing_No_field_map() {

local PATH_T1_OUTPUT="$1"
local PATH_DWI_OUTPUT="$2"

<< --MULTILINE-COMMENT--
# Transform the coordinate
gunzip -k ${PATH_DWI_OUTPUT}/*.nii.gz
mv ${PATH_DWI_OUTPUT}/*.nii ${PATH_DWI_OUTPUT}/data.nii
mv ${PATH_DWI_OUTPUT}/*.bval ${PATH_DWI_OUTPUT}/bvals
mv ${PATH_DWI_OUTPUT}/*.bvec ${PATH_DWI_OUTPUT}/bvecs
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
# When field map is empty, extract the brain from the raw data b0
echo 'b0 extraction'
fslroi ${PATH_DWI_OUTPUT}/data.nii ${PATH_DWI_OUTPUT}/b0 0 1
echo 'BET b0'
bet ${PATH_DWI_OUTPUT}/b0.nii.gz ${PATH_DWI_OUTPUT}/b0_brain -m -f 0.2 #"-m" is used to create the mask
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "BEDPOSTX"
mkdir ${PATH_DWI_OUTPUT}/BEDPOSTX
echo "Copying files for BedpostX"
cp ${PATH_DWI_OUTPUT}/data.nii ${PATH_DWI_OUTPUT}/BEDPOSTX/data.nii
cp ${PATH_DWI_OUTPUT}/b0_brain_mask.nii.gz ${PATH_DWI_OUTPUT}/BEDPOSTX/nodif_brain_mask.nii.gz #We only need the brain mask in the bedpostX folder
cp ${PATH_DWI_OUTPUT}/bvecs ${PATH_DWI_OUTPUT}/BEDPOSTX/bvecs
cp ${PATH_DWI_OUTPUT}/bvals ${PATH_DWI_OUTPUT}/BEDPOSTX/bvals
bedpostx ${PATH_DWI_OUTPUT}/BEDPOSTX -n 2 -model 1
echo "BEDPOSTX is done"
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "Tractography"
mkdir ${PATH_DWI_OUTPUT}/PROBTRACKX
fslmaths ${PATH_T1_OUTPUT}/c3wT1.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/CSF_mask_0.5
fslmaths ${PATH_T1_OUTPUT}/c2wT1.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/WM_mask_0.5
flirt -in ${PATH_DWI_OUTPUT}/b0_brain -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz -omat ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/diff2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -cost corratio
convert_xfm -omat ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/str2diff.mat -inverse ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/diff2str.mat
echo "${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz" >> ${PATH_DWI_OUTPUT}/PROBTRACKX/waypoints.txt
probtrackx2 -x ${PATH_T1_OUTPUT}/WM_mask_0.5.nii.gz -V 1 -l --onewaycondition --omatrix3 --target3=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz --lrtarget3=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz -c 0.2 -S 2000 --steplength=0.5 -P 1000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/str2diff.mat --avoid=${PATH_T1_OUTPUT}/CSF_mask_0.5.nii.gz --stop=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz --forcedir --opd -s ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/merged -m ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/nodif_brain_mask --dir=${PATH_DWI_OUTPUT}/PROBTRACKX --waypoints=${PATH_DWI_OUTPUT}/PROBTRACKX/waypoints.txt --waycond=AND
--MULTILINE-COMMENT--

}


function DWI_processing_With_field_map() {

local PATH_T1_OUTPUT="$1"
local PATH_DWI_OUTPUT="$2"
local PATH_FIELDMAP_OUTPUT="$3"

<< --MULTILINE-COMMENT--
gunzip -k ${PATH_DWI_OUTPUT}/*.nii.gz
mv ${PATH_DWI_OUTPUT}/*.nii ${PATH_DWI_OUTPUT}/data.nii
mv ${PATH_DWI_OUTPUT}/*.bval ${PATH_DWI_OUTPUT}/bvals
mv ${PATH_DWI_OUTPUT}/*.bvec ${PATH_DWI_OUTPUT}/bvecs
mv ${PATH_FIELDMAP_OUTPUT}/*.nii ${PATH_FIELDMAP_OUTPUT}/phase.nii
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'b0 extraction'
fslroi ${PATH_DWI_OUTPUT}/data.nii ${PATH_DWI_OUTPUT}/b0 0 1
echo 'BET b0'
bet ${PATH_DWI_OUTPUT}/b0.nii.gz ${PATH_DWI_OUTPUT}/b0_brain -m -f 0.2
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "Prepare fieldmap for eddy"
echo '2.Bring the phase to the T1 space'
flirt -in ${PATH_FIELDMAP_OUTPUT}/phase.nii -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz -dof 6 -omat ${PATH_FIELDMAP_OUTPUT}/phase_to_T1 -applyxfm -usesqform -out ${PATH_FIELDMAP_OUTPUT}/phase_to_T1
echo '3.Matrix Inversion'
convert_xfm -omat ${PATH_FIELDMAP_OUTPUT}/inv_phase_to_T1 -inverse ${PATH_FIELDMAP_OUTPUT}/phase_to_T1
echo '4. Brain mask to PHASEspace'
flirt -in ${PATH_T1_OUTPUT}/brain_mask.nii.gz -ref ${PATH_FIELDMAP_OUTPUT}/phase.nii -applyxfm -init ${PATH_FIELDMAP_OUTPUT}/inv_phase_to_T1 -o ${PATH_FIELDMAP_OUTPUT}/wT1_brain_spm_mask_PHASEspace
echo '4b. Jesper Step1'
fslmaths ${PATH_FIELDMAP_OUTPUT}/wT1_brain_spm_mask_PHASEspace -thr 0.5 ${PATH_FIELDMAP_OUTPUT}/wT1_brain_spm_mask_PHASEspace_jesper
echo '5.Prepare fieldmap'
fsl_prepare_fieldmap SIEMENS ${PATH_FIELDMAP_OUTPUT}/phase.nii ${PATH_FIELDMAP_OUTPUT}/wT1_brain_spm_mask_PHASEspace_jesper ${PATH_FIELDMAP_OUTPUT}/field_map_rad_s 2.46
echo '6.Transforming the field_map to Hz units'
fslmaths ${PATH_FIELDMAP_OUTPUT}/field_map_rad_s -div 6.2831853072 ${PATH_FIELDMAP_OUTPUT}/field_map_Hz
echo '7.Bring the field_map to the DWI space'
flirt -in ${PATH_FIELDMAP_OUTPUT}/field_map_Hz -ref ${PATH_DWI_OUTPUT}/b0_brain.nii.gz -dof 6 -omat ${PATH_FIELDMAP_OUTPUT}/field_map_Hz_to_b0_mat -applyxfm -usesqform -out ${PATH_FIELDMAP_OUTPUT}/field_map_Hz_to_b0
echo '7b. Jesper Step2'
fslmaths ${PATH_FIELDMAP_OUTPUT}/field_map_Hz_to_b0 -s 2.5 ${PATH_FIELDMAP_OUTPUT}/field_map_Hz_to_b0_s
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "Running eddy"
eddy --imain=${PATH_DWI_OUTPUT}/data.nii --acqp=acqparams_004386.txt --index=index.txt --bvecs=${PATH_DWI_OUTPUT}/bvecs --bvals=${PATH_DWI_OUTPUT}/bvals --mask=${PATH_DWI_OUTPUT}/b0_brain_mask.nii.gz --field=${PATH_FIELDMAP_OUTPUT}/field_map_Hz_to_b0_s --repol --cnr_maps --very_verbose --out=${PATH_DWI_OUTPUT}/myeddy
echo "Eddy END"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "BEDPOSTX"
fslroi ${PATH_DWI_OUTPUT}/myeddy.nii.gz ${PATH_DWI_OUTPUT}/eddy_b0 0 1
bet ${PATH_DWI_OUTPUT}/eddy_b0.nii.gz ${PATH_DWI_OUTPUT}/eddy_b0_brain -m -f 0.2
mkdir ${PATH_DWI_OUTPUT}/BEDPOSTX
echo "Copying files for BedpostX"
cp ${PATH_DWI_OUTPUT}/myeddy.nii.gz ${PATH_DWI_OUTPUT}/BEDPOSTX/data.nii.gz
cp ${PATH_DWI_OUTPUT}/eddy_b0_brain_mask.nii.gz ${PATH_DWI_OUTPUT}/BEDPOSTX/nodif_brain_mask.nii.gz
cp ${PATH_DWI_OUTPUT}/myeddy.eddy_rotated_bvecs ${PATH_DWI_OUTPUT}/BEDPOSTX/bvecs
cp ${PATH_DWI_OUTPUT}/bvals ${PATH_DWI_OUTPUT}/BEDPOSTX/bvals
bedpostx ${PATH_DWI_OUTPUT}/BEDPOSTX -n 2 -model 1
echo "BEDPOSTX is done"
--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--
echo "Tractography"
mkdir ${PATH_DWI_OUTPUT}/PROBTRACKX
fslmaths ${PATH_T1_OUTPUT}/c3wT1.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/CSF_mask_0.5
fslmaths ${PATH_T1_OUTPUT}/c2wT1.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/WM_mask_0.5
flirt -in ${PATH_DWI_OUTPUT}/eddy_b0_brain -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz -omat ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/diff2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 6 -cost corratio
convert_xfm -omat ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/str2diff.mat -inverse ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/diff2str.mat
echo "${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz" >> ${PATH_DWI_OUTPUT}/PROBTRACKX/waypoints.txt
probtrackx2 -x ${PATH_T1_OUTPUT}/WM_mask_0.5.nii.gz -V 1 -l --onewaycondition --omatrix3 --target3=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz --lrtarget3=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz -c 0.2 -S 2000 --steplength=0.5 -P 1000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/xfms/str2diff.mat --avoid=${PATH_T1_OUTPUT}/CSF_mask_0.5.nii.gz --stop=${PATH_T1_OUTPUT}/GM_mask_0.5.nii.gz --forcedir --opd -s ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/merged -m ${PATH_DWI_OUTPUT}/BEDPOSTX.bedpostX/nodif_brain_mask --dir=${PATH_DWI_OUTPUT}/PROBTRACKX --waypoints=${PATH_DWI_OUTPUT}/PROBTRACKX/waypoints.txt --waycond=AND
--MULTILINE-COMMENT--

}
