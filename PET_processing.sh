function PET_processing() {

local PATH_PET_OUTPUT="$1"
local PATH_T1_OUTPUT="$2"
local PATH_CC_OUTPUT="$3"

<< --MULTILINE-COMMENT--
echo 'Data preprocessing';
gunzip -k ${PATH_PET_OUTPUT}/*.nii.gz
dcm2niix -t y ${PATH_PET_OUTPUT}
mv -v ${PATH_PET_OUTPUT}/*.nii ${PATH_PET_OUTPUT}/PET_30min.nii
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo 'Linear registration of T1 to PET'
flirt -in ${PATH_T1_OUTPUT}/wT1.nii -ref ${PATH_PET_OUTPUT}/PET_30min.nii -out ${PATH_PET_OUTPUT}/T1_to_PET_30min.nii -omat ${PATH_PET_OUTPUT}/T1_to_PET_mat
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'Split ATLAS in T1 space'
for var in {1..120}
do
echo "$var"
fslmaths ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5.nii -thr $var -uthr $var ${PATH_CC_OUTPUT}/AAL2_roi_$var.nii.gz
fslmaths ${PATH_CC_OUTPUT}/AAL2_roi_$var.nii.gz -bin ${PATH_CC_OUTPUT}/AAL2_bin_roi_$var.nii.gz
done;
--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--
echo 'ATLAS to PET space'
flirt -in ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5.nii -ref ${PATH_PET_OUTPUT}/PET_30min.nii -applyxfm  -init ${PATH_PET_OUTPUT}/T1_to_PET_mat -out ${PATH_PET_OUTPUT}/AAL2_to_PET_0p5.nii -interp nearestneighbour
echo 'Split ATLAS in PET space'

mkdir -p "$PATH_PET_OUTPUT/Slice"
for var in {1..120}
do
echo "$var"
fslmaths ${PATH_PET_OUTPUT}/AAL2_to_PET_0p5.nii -thr $var -uthr $var ${PATH_PET_OUTPUT}/Slice/AAL2_to_PET_roi_$var.nii.gz
fslmaths ${PATH_PET_OUTPUT}/Slice/AAL2_to_PET_roi_$var.nii.gz -bin ${PATH_PET_OUTPUT}/Slice/AAL2_to_PET_bin_roi_$var.nii.gz
done;
--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--
echo "FDGuptake extraction"

for var in {1..120}
do
echo "$var"
fslmaths ${PATH_PET_OUTPUT}/Slice/AAL2_to_PET_bin_roi_$var.nii.gz -mul ${PATH_PET_OUTPUT}/PET_30min.nii ${PATH_PET_OUTPUT}/Slice/PET_AAL2_roi_$var.nii.gz

fslstats ${PATH_PET_OUTPUT}/Slice/PET_AAL2_roi_$var.nii.gz -M >> ${PATH_PET_OUTPUT}/FDG_120.txt;
done;

echo 'FDGuptake in entire ATLAS'

fslmaths ${PATH_PET_OUTPUT}/AAL2_to_PET_0p5.nii -bin ${PATH_PET_OUTPUT}/bin_AAL2_to_PET_0p5.nii.gz;

fslmaths ${PATH_PET_OUTPUT}/bin_AAL2_to_PET_0p5.nii -mul ${PATH_PET_OUTPUT}/PET_30min.nii ${PATH_PET_OUTPUT}/PET_30min_AAL2.nii;

fslstats ${PATH_PET_OUTPUT}/PET_30min_AAL2.nii -M >> ${PATH_PET_OUTPUT}/FDG_AAL2.txt;
--MULTILINE-COMMENT--


}
