function T1_processing() {

local PATH_T1_OUTPUT="$1"

# Define the path for ANT packages
export PATH=/media/dingzhou/Matlab/Data_Processing_Neuroscience/New/ANT/install/bin:$PATH

<< --MULTILINE-COMMENT--
gunzip -k ${PATH_T1_OUTPUT}/*.nii.gz
mv ${PATH_T1_OUTPUT}/*.nii ${PATH_T1_OUTPUT}/wT1.nii
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
new_path="${PATH_T1_OUTPUT}/wT1.nii,1"
input_file="Segment_job.m"
sed -i "s@matlabbatch{1}.spm.spatial.preproc.channel.vols = {'.*'};@matlabbatch{1}.spm.spatial.preproc.channel.vols = {'$new_path'};@" "$input_file"
matlab -r "Segment; exit;"
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
cp ${PATH_T1_OUTPUT}/c1wT1.nii ${PATH_T1_OUTPUT}/c1wT1_backup.nii
mv ${PATH_T1_OUTPUT}/c1wT1_backup.nii ${PATH_T1_OUTPUT}/GM.nii
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "Brain extraction"
fslmaths ${PATH_T1_OUTPUT}/c1wT1.nii.gz -add ${PATH_T1_OUTPUT}/c2wT1.nii.gz -add ${PATH_T1_OUTPUT}/c3wT1.nii.gz -bin ${PATH_T1_OUTPUT}/brain_mask.nii.gz
fslmaths ${PATH_T1_OUTPUT}/wT1.nii.gz -mul ${PATH_T1_OUTPUT}/brain_mask.nii.gz ${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "MNI_to_T1 Registration"
output_mat="${PATH_T1_OUTPUT}/MNI_to_T1"
output="${PATH_T1_OUTPUT}/MNI_to_T1.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="./MNI152_T1_1mm_brain.nii.gz"

antsRegistration --dimensionality 3 --float 0 --output [$output_mat , $output] --interpolation Linear --winsorize-image-intensities [0.005,0.995] --use-histogram-matching 1   --initial-moving-transform [$ref_input,$mov_input,1]   --transform Rigid[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]  --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox  --transform Affine[0.1]   --metric MI[$ref_input,$mov_input,1,32,Regular,0.25]   --convergence [1000x500x250x100,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox     --transform SyN[0.1,3,0]   --metric CC[$ref_input,$mov_input,1,4]   --convergence [100x70x50x20,1e-6,10]   --shrink-factors 8x4x2x1   --smoothing-sigmas 3x2x1x0vox
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "AAL2_to_T1 Atlas"
output="${PATH_T1_OUTPUT}/AAL2_to_T1.nii.gz"
ref_input="${PATH_T1_OUTPUT}/wT1_brain_spm.nii.gz"
mov_input="rAAL2_1mm.nii"
transformation3="${PATH_T1_OUTPUT}/MNI_to_T11Warp.nii.gz"
transformation4="${PATH_T1_OUTPUT}/MNI_to_T10GenericAffine.mat"

antsApplyTransforms -d 3 -i $mov_input -r $ref_input -n NearestNeighbor -t $transformation3 -t $transformation4 -o $output
fslmaths ${PATH_T1_OUTPUT}/GM.nii -thr 0.5 -bin ${PATH_T1_OUTPUT}/GM_mask_0.5.nii
fslmaths ${PATH_T1_OUTPUT}/AAL2_to_T1.nii -mul ${PATH_T1_OUTPUT}/GM_mask_0.5.nii ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5.nii
--MULTILINE-COMMENT--



}
