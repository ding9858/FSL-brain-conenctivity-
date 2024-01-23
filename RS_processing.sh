function RS_processing() {

export PATH=/media/dingzhou/Matlab/Data_Processing_Neuroscience/New/ANT/install/bin:$PATH
local PATH_RS_OUTPUT="$1"
local PATH_T1_OUTPUT="$2"


<< --MULTILINE-COMMENT--
echo 'DICOM to NIFTI';
gunzip -k ${PATH_RS_OUTPUT}/*.nii.gz
dcm2niix -t y ${PATH_RS_OUTPUT}
mv -v ${PATH_RS_OUTPUT}/*.nii ${PATH_RS_OUTPUT}/resting.nii
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'Delete the first 3 volumes';
fslroi ${PATH_RS_OUTPUT}/resting.nii ${PATH_RS_OUTPUT}/resting_1.nii.gz 3 209
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# Diagnostic with tsdiffana
# Opening MATLAB to run rest_diagnostic
new_path="${PATH_RS_OUTPUT}"
input_file="rest_diagnostic.m"
sed -i "s@folder=strcat('.*');@folder=strcat('$new_path/');@" "$input_file"
matlab -r "rest_diagnostic; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# SPM STEPS (for Slice timing & Realignment)
mkdir -p "$PATH_RS_OUTPUT/Slice"

fslsplit ${PATH_RS_OUTPUT}/resting_1.nii.gz ${PATH_RS_OUTPUT}/Slice/vol #that's how they have to be for SPM
for r in {0000..0208}
	do
	gzip -d ${PATH_RS_OUTPUT}/Slice/vol$r.nii.gz #that's how they have to be for SPM
done;
echo 'done'
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# In Matlab run Slice_Timing.m to perform slice timing correction.
new_path="${PATH_RS_OUTPUT}"
input_file="Slice_Timing_job.m"
sed -i "s|'./output/[^/]\+/[^/]\+/func/|'$new_path/|g" "$input_file"
matlab -r "Slice_Timing; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# In Matlab run Reslice.m to perform slice Realignment.
new_path="${PATH_RS_OUTPUT}"
input_file="Reslice_job.m"
sed -i "s|'./output/[^/]\+/[^/]\+/func/|'$new_path/|g" "$input_file"
matlab -r "Reslice; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'Merging data'
fslmerge -t ${PATH_RS_OUTPUT}/merge.nii ${PATH_RS_OUTPUT}/Slice/ravol*.nii #Join the 209 volumes to continue with the processing out of SPM
gzip -d ${PATH_RS_OUTPUT}/merge.nii.gz
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# In Matlab run rest_pasabanda to apply a bandpass filter to merge.nii
gunzip -k ${PATH_RS_OUTPUT}/merge.nii.gz
new_path="${PATH_RS_OUTPUT}"
input_file="rest_pasabanda.m"
sed -i "s@path_subject=strcat('.*');@path_subject=strcat('$new_path/');@" "$input_file"
matlab -r "rest_pasabanda; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'T1 to BOLD coregistration'
bet2 ${PATH_RS_OUTPUT}/Slice/ravol0104.nii ${PATH_RS_OUTPUT}/_ravol0104_brain -m -f 0.2
gzip -d ${PATH_RS_OUTPUT}/_ravol0104_brain.nii.gz
flirt -in ${PATH_T1_OUTPUT}/wT1_brain_spm.nii -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -out ${PATH_RS_OUTPUT}/T1_to_BOLD -omat ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -dof 6
flirt -in ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii -out ${PATH_RS_OUTPUT}/BOLD_to_T1 -omat ${PATH_RS_OUTPUT}/BOLD_to_T1_mat -dof 6
convert_xfm -omat ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -inverse ${PATH_RS_OUTPUT}/BOLD_to_T1_mat
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# use 0p5, 0p5 looks better than 0p999
echo 'MASKS from T1 to BOLD space'
fslmaths ${PATH_T1_OUTPUT}/c2wT1.nii -thr 0.999 ${PATH_RS_OUTPUT}/WM_mask_0p999.nii.gz
fslmaths ${PATH_T1_OUTPUT}/c3wT1.nii -thr 0.999 ${PATH_RS_OUTPUT}/CSF_mask_0p999.nii.gz

fslmaths ${PATH_T1_OUTPUT}/GM.nii -thr 0.999 -bin ${PATH_RS_OUTPUT}/GM_mask_0p999.nii
fslmaths ${PATH_T1_OUTPUT}/AAL2_to_T1.nii -mul ${PATH_RS_OUTPUT}/GM_mask_0p999.nii ${PATH_RS_OUTPUT}/AAL2_to_T1_0p999.nii

flirt -interp nearestneighbour -in ${PATH_RS_OUTPUT}/WM_mask_0p999 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/WM_0p999_to_BOLD
flirt -interp nearestneighbour -in ${PATH_RS_OUTPUT}/CSF_mask_0p999 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/CSF_0p999_to_BOLD
flirt -interp nearestneighbour -in ${PATH_RS_OUTPUT}/AAL2_to_T1_0p999 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/AAL2_0p999_to_BOLD


fslmaths ${PATH_T1_OUTPUT}/c2wT1.nii -thr 0.5 ${PATH_RS_OUTPUT}/WM_mask_0p5.nii.gz
fslmaths ${PATH_T1_OUTPUT}/c3wT1.nii -thr 0.5 ${PATH_RS_OUTPUT}/CSF_mask_0p5.nii.gz

flirt -interp nearestneighbour -in ${PATH_RS_OUTPUT}/WM_mask_0p5 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/WM_0p5_to_BOLD
flirt -interp nearestneighbour -in ${PATH_RS_OUTPUT}/CSF_mask_0p5 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/CSF_0p5_to_BOLD
flirt -interp nearestneighbour -in ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5 -ref ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -applyxfm -init ${PATH_RS_OUTPUT}/T1_to_BOLD_mat -out ${PATH_RS_OUTPUT}/AAL2_0p5_to_BOLD
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'WM & CSF signal extraction'

fslmeants -i ${PATH_RS_OUTPUT}/merge_filtered.nii -o ${PATH_RS_OUTPUT}/media_CSF_0p5.txt -m ${PATH_RS_OUTPUT}/CSF_0p5_to_BOLD.nii
fslmeants -i ${PATH_RS_OUTPUT}/merge_filtered.nii -o ${PATH_RS_OUTPUT}/media_WM_0p5.txt -m ${PATH_RS_OUTPUT}/WM_0p5_to_BOLD.nii
fslmeants -i ${PATH_RS_OUTPUT}/merge_filtered.nii -o ${PATH_RS_OUTPUT}/media_AAL2_0p5.txt -m ${PATH_RS_OUTPUT}/AAL2_0p5_to_BOLD.nii
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# 'In MATLAB: regressors' #To combine the two txts (2 seconds)
new_path="${PATH_RS_OUTPUT}"
input_file="regressors.m"
sed -i "s@path_subject=strcat('.*');@path_subject=strcat('$new_path/');@" "$input_file"
matlab -r "regressors; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'WM & CSF signal regression'
echo 'running fsl_glm'
fsl_glm -i ${PATH_RS_OUTPUT}/merge_filtered.nii.gz -d ${PATH_RS_OUTPUT}/csf_wm_mov_regressors.mat -o ${PATH_RS_OUTPUT}/merge_regress_no_demean.nii.gz
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
#STEP 13 (ROI signal extraction)
echo 'Step 13: ROI signal extraction'
echo 'Masking ATLAS'
fslmaths ${PATH_RS_OUTPUT}/_ravol0104_brain_mask -mul ${PATH_RS_OUTPUT}/AAL2_0p5_to_BOLD.nii ${PATH_RS_OUTPUT}/AAL2_0p5_to_BOLD_masked.nii

echo 'Split ROIs'
for var in {1..100}
do
fslmaths ${PATH_RS_OUTPUT}/AAL2_0p5_to_BOLD_masked.nii -thr $var -uthr $var ${PATH_RS_OUTPUT}/Slice/AAL2_roi_$var

done;

#echo 'Combining 113 and 114 regions'
#fslmaths ${PATH_RS_OUTPUT}/roi_113.nii.gz -add ${PATH_RS_OUTPUT}/roi_114.nii.gz ${PATH_RS_OUTPUT}/roi_113.nii.gz
#echo 'Removing 114 region'
#rm ${PATH_RS_OUTPUT}/roi_114.nii.gz
#echo 'Renaming Vermis regions'
#cp ${PATH_RS_OUTPUT}/roi_115.nii.gz ${PATH_RS_OUTPUT}/roi_114.nii.gz
#cp ${PATH_RS_OUTPUT}/roi_116.nii.gz ${PATH_RS_OUTPUT}/roi_115.nii.gz
#cp ${PATH_RS_OUTPUT}/roi_117.nii.gz ${PATH_RS_OUTPUT}/roi_116.nii.gz
#cp ${PATH_RS_OUTPUT}/roi_118.nii.gz ${PATH_RS_OUTPUT}/roi_117.nii.gz
#cp ${PATH_RS_OUTPUT}/roi_119.nii.gz ${PATH_RS_OUTPUT}/roi_118.nii.gz
#cp ${PATH_RS_OUTPUT}/roi_120.nii.gz ${PATH_RS_OUTPUT}/roi_119.nii.gz

echo 'mean ROI signal extraction (aprox 8 min)'
for var in {1..100}
do
fslmeants -i ${PATH_RS_OUTPUT}/merge_regress_no_demean.nii -o ${PATH_RS_OUTPUT}/Slice/merge_regress_no_demean_AAL2_roi_$var.txt -m ${PATH_RS_OUTPUT}/Slice/AAL2_roi_$var.nii.gz

done;

echo 'Step 13 completed';

--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
#Step 14 (Functional Connectivity)
echo 'Step 14: Functional Connectivity'
pause 'Run Pearson in MATLAB to obtain the FC networks' #OPTIONAL: run graphs_theory to calculate metrics and grafos to visualize the 3D graph'
echo 'Step 14 ended'
new_path="${PATH_RS_OUTPUT}"
input_file="FC.m"
sed -i "s@path_subject=strcat('.*'/Slice/);@path_subject=strcat('$new_path'/Slice);@" "$input_file"
matlab -r "FC; exit;"
--MULTILINE-COMMENT--
}
