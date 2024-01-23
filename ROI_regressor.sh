function ROI_regressor() {

local PATH_T1_OUTPUT="$1"
local PATH_PET_OUTPUT="$2"
local PATH_ROI_OUTPUT="$3"
local PATH_RS_OUTPUT="$4"
local PATH_DWI_OUTPUT="$5"

export PATH=/media/dingzhou/Matlab/Data_Processing_Neuroscience/New/ANT/install/bin:$PATH
#<< --MULTILINE-COMMENT--
# Used to registrate
bet2 ${PATH_PET_OUTPUT}/PET_30min.nii ${PATH_ROI_OUTPUT}/PET_brain -m -f 0.2
flirt -in ${PATH_ROI_OUTPUT}/PET_brain.nii -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii -out ${PATH_ROI_OUTPUT}/PET_to_T1 -omat ${PATH_ROI_OUTPUT}/PET_to_T1_mat -dof 6
flirt -in ${PATH_RS_OUTPUT}/_ravol0104_brain.nii -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii -out ${PATH_ROI_OUTPUT}/BOLD_to_T1 -omat ${PATH_ROI_OUTPUT}/BOLD_to_T1_mat -dof 6
flirt -in ${PATH_DWI_OUTPUT}/b0_brain.nii -ref ${PATH_T1_OUTPUT}/wT1_brain_spm.nii -out ${PATH_ROI_OUTPUT}/DWI_to_T1 -omat ${PATH_ROI_OUTPUT}/DWI_to_T1_mat -dof 6

#--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "PET_to_T1 Registration"
output_mat="${PATH_ROI_OUTPUT}/PET_to_T1"
output="${PATH_ROI_OUTPUT}/PET_to_T1.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="${PATH_PET_OUTPUT}/PET_30min.nii"

antsRegistration --dimensionality 3 --float 0 --output [$output_mat , $output] --interpolation Linear --winsorize-image-intensities [0.005,0.995] --use-histogram-matching 1   --initial-moving-transform [$ref_input,$mov_input,1]   --transform Rigid[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]  --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox  --transform Affine[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox     --transform SyN[0.1,3,0]   --metric CC[$ref_input,$mov_input,1,4]   --convergence [100x70x50x20,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "AAL2_to_PET_T1_Format Atlas"
output="${PATH_ROI_OUTPUT}/AAL2_to_PET_T1_Format.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="rAAL2_1mm.nii"
transformation3="${PATH_ROI_OUTPUT}/PET_to_T11Warp.nii.gz"
transformation4="${PATH_ROI_OUTPUT}/PET_to_T10GenericAffine.mat"

antsApplyTransforms -d 3 -i $mov_input -r $ref_input -n NearestNeighbor -t $transformation3 -t $transformation4 -o $output
#fslmaths ${PATH_T1_OUTPUT}/GM.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/GM_mask_0.5.nii
fslmaths ${PATH_ROI_OUTPUT}/AAL2_to_PET_T1_Format.nii -mul ${PATH_T1_OUTPUT}/GM_mask_0.5.nii ${PATH_ROI_OUTPUT}/AAL2_to_PET_T1_Format_0p5.nii
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "MNI_to_PET Registration"
output_mat="${PATH_ROI_OUTPUT}/MNI_to_PET"
output="${PATH_ROI_OUTPUT}/MNI_to_PET.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="./MNI152_T1_1mm_brain.nii.gz"

antsRegistration --dimensionality 3 --float 0 --output [$output_mat , $output] --interpolation Linear --winsorize-image-intensities [0.005,0.995] --use-histogram-matching 1   --initial-moving-transform [$ref_input,$mov_input,1]   --transform Rigid[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]  --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox  --transform Affine[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox     --transform SyN[0.1,3,0]   --metric CC[$ref_input,$mov_input,1,4]   --convergence [100x70x50x20,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "AAL2_to_PET Atlas"
output="${PATH_ROI_OUTPUT}/AAL2_to_PET.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="rAAL2_1mm.nii"
transformation3="${PATH_T1_OUTPUT}/MNI_to_T11Warp.nii.gz"
transformation4="${PATH_T1_OUTPUT}/MNI_to_T10GenericAffine.mat"

antsApplyTransforms -d 3 -i $mov_input -r $ref_input -n NearestNeighbor -t $transformation3 -t $transformation4 -o $output
#fslmaths ${PATH_T1_OUTPUT}/GM.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/GM_mask_0.5.nii
fslmaths ${PATH_ROI_OUTPUT}/AAL2_to_PET.nii -mul ${PATH_T1_OUTPUT}/GM_mask_0.5.nii ${PATH_ROI_OUTPUT}/AAL2_to_PET_0p5.nii
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
mkdir -p "$PATH_ROI_OUTPUT/PET2_Slice"
for var in {1..120}
do
echo "$var PET"
fslmaths ${PATH_ROI_OUTPUT}/AAL2_to_PET_0p5.nii -thr $var -uthr $var ${PATH_ROI_OUTPUT}/PET2_Slice/AAL2_to_PET_roi_$var.nii.gz
fslmaths ${PATH_ROI_OUTPUT}/PET2_Slice/AAL2_to_PET_roi_$var.nii.gz -bin ${PATH_ROI_OUTPUT}/PET2_Slice/AAL2_to_PET_bin_roi_$var.nii.gz
done;
--MULTILINE-COMMENT--
<< --MULTILINE-COMMENT--
mkdir -p "$PATH_ROI_OUTPUT/PET_Slice"
for var in {1..120}
do
echo "$var PET"
fslmaths ${PATH_ROI_OUTPUT}/AAL2_to_PET_T1_Format_0p5.nii -thr $var -uthr $var ${PATH_ROI_OUTPUT}/PET_Slice/AAL2_to_PET_roi_$var.nii.gz
fslmaths ${PATH_ROI_OUTPUT}/PET_Slice/AAL2_to_PET_roi_$var.nii.gz -bin ${PATH_ROI_OUTPUT}/PET_Slice/AAL2_to_PET_bin_roi_$var.nii.gz
done;

mkdir -p "$PATH_ROI_OUTPUT/T1_Slice"
for var in {1..120}
do
echo "$var T1"
fslmaths ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5.nii -thr $var -uthr $var ${PATH_ROI_OUTPUT}/T1_Slice/AAL2_to_T1_roi_$var.nii.gz
fslmaths ${PATH_ROI_OUTPUT}/T1_Slice/AAL2_to_T1_roi_$var.nii.gz -bin ${PATH_ROI_OUTPUT}/T1_Slice/AAL2_to_T1_bin_roi_$var.nii.gz
done;
--MULTILINE-COMMENT--




<< --MULTILINE-COMMENT--
rm ${PATH_ROI_OUTPUT}/GM_density_T1.txt
rm ${PATH_ROI_OUTPUT}/GM_density_PET.txt
rm ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt
rm ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt
touch ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt
touch ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt
touch ${PATH_ROI_OUTPUT}/GM_density_T1.txt
touch ${PATH_ROI_OUTPUT}/GM_density_PET.txt

for var in {1..120}
do
echo "$var"
fslmaths ${PATH_ROI_OUTPUT}/T1_Slice/AAL2_to_T1_bin_roi_$var.nii.gz -mul  ${PATH_T1_OUTPUT}/GM_0.5.nii.gz ${PATH_ROI_OUTPUT}/T1_Slice/density_AAL2_to_T1_roi_$var.nii.gz
fslstats ${PATH_ROI_OUTPUT}/T1_Slice/density_AAL2_to_T1_roi_$var.nii.gz -m >> ${PATH_ROI_OUTPUT}/GM_density_T1.txt;


fslmaths ${PATH_ROI_OUTPUT}/PET_Slice/AAL2_to_PET_bin_roi_$var.nii.gz -mul  ${PATH_T1_OUTPUT}/GM_0.5.nii.gz ${PATH_ROI_OUTPUT}/PET_Slice/density_AAL2_to_PET_roi_$var.nii.gz
fslstats ${PATH_ROI_OUTPUT}/PET_Slice/density_AAL2_to_PET_roi_$var.nii.gz -m >> ${PATH_ROI_OUTPUT}/GM_density_PET.txt;
done;
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
rm ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt
rm ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt
touch ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt
touch ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt

echo 'GM Volume'
for var in {1..120}
do
echo "$var"
fslstats ${PATH_ROI_OUTPUT}/PET_Slice/density_AAL2_to_PET_roi_$var.nii.gz -V >> ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt;

echo 'd: Total Volume'
fslstats ${PATH_ROI_OUTPUT}/T1_Slice/density_AAL2_to_T1_roi_$var.nii.gz -V >> ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt;
done;

--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--

rm ${PATH_ROI_OUTPUT}/GM_volumes_regress.txt
touch ${PATH_ROI_OUTPUT}/GM_volumes_regress.txt
echo "Step 5.b: Total GMV regression"
fsl_glm -i ${PATH_ROI_OUTPUT}/GM_volumes_PET.txt -d ${PATH_ROI_OUTPUT}/GM_volumes_T1.txt --out_res=${PATH_ROI_OUTPUT}/GM_volumes_regress.txt

--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "Center of gravity"

rm ${PATH_ROI_OUTPUT}/Centers_of_gravity_T1.txt;
rm ${PATH_ROI_OUTPUT}/Centers_of_gravity_PET.txt;

for var in {1..106}
do
echo "$var"
fslstats ${PATH_ROI_OUTPUT}/T1_Slice/AAL2_to_T1_bin_roi_$var.nii.gz  -c >> ${PATH_ROI_OUTPUT}/Centers_of_gravity_T1.txt;
fslstats ${PATH_ROI_OUTPUT}/PET_Slice/AAL2_to_PET_bin_roi_$var.nii.gz  -c >> ${PATH_ROI_OUTPUT}/Centers_of_gravity_PET.txt;
done;
--MULTILINE-COMMENT--


}
