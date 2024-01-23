# Author: Ding Zhou
# Supervisor: Yifan Mayr, Prof. Dr. Igor Yakushev
# Institute: Technical University of Munich
# Description: A pipeline combines the data processing of neuroscience imaging

source DWI_processing.sh
source T1_processing.sh
source RS_processing.sh
source Connectivity_processing.sh
source PET_processing.sh
source ROI_regressor.sh

echo "----------Data Preprocessing Start----------"
# To access the data and print the location of the data
echo
for i in ./data/*; do
if [ -d "$i" ]; then
echo "Accessing: $i"
echo
for j in "$i"/*; do
if [ -d "$j" ]; then
echo "Accessing: $j"
echo

path="$j"

<< --MULTILINE-COMMENT--
# T1 processing
echo "----------T1 Processing Start"
PATH_T1_INPUT="${path}/anat"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
mkdir -p "$PATH_T1_OUTPUT"
cp "${PATH_T1_INPUT}"/* "${PATH_T1_OUTPUT}/"
T1_processing "$PATH_T1_OUTPUT"
echo "----------T1 Processing End"
echo
--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--
# DWI processing
echo "----------DWI Processing Start"
# To check if the field map of the DWI data is empty or not
if [ ! "$(ls -A $path/fmap)" ];then
echo "Field Map empty, processe without fieldmap"
PATH_DWI_INPUT="${path}/dwi"
PATH_DWI_OUTPUT="${j/\/data\//\/output\/}/dwi"
#mkdir -p "$PATH_DWI_OUTPUT"
#cp "${PATH_DWI_INPUT}"/* "${PATH_DWI_OUTPUT}/"
DWI_processing_No_field_map "$PATH_T1_OUTPUT" "$PATH_DWI_OUTPUT"
else
echo "Field Map Exist, processe with fieldmap"
PATH_DWI_INPUT="${path}/dwi"
PATH_FIELDMAP_INPUT="$path/fmap"
PATH_DWI_OUTPUT="${j/\/data\//\/output\/}/dwi"
PATH_FIELDMAP_OUTPUT="${j/\/data\//\/output\/}/fmap"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
#mkdir -p "$PATH_DWI_OUTPUT"
#mkdir -p "$PATH_FIELDMAP_OUTPUT"
#cp "${PATH_DWI_INPUT}"/* "${PATH_DWI_OUTPUT}/"
#cp "${PATH_FIELDMAP_INPUT}"/* "${PATH_FIELDMAP_OUTPUT}/"
DWI_processing_With_field_map "$PATH_T1_OUTPUT" "$PATH_DWI_OUTPUT" "$PATH_FIELDMAP_OUTPUT"
fi

echo "----------DWI Processing End"
echo
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
# fMRI resting state processing
echo "----------Resting State Processing Start"
PATH_RS_INPUT="${path}/func"
PATH_RS_OUTPUT="${j/\/data\//\/output\/}/func"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
mkdir -p "$PATH_RS_OUTPUT"
cp "${PATH_RS_INPUT}"/* "${PATH_RS_OUTPUT}/"
RS_processing "$PATH_RS_OUTPUT" "$PATH_T1_OUTPUT"
echo "----------Resting State Processing End"
echo
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# Connectivity Processing
echo "----------Connectivity Analysis Start"
PATH_CC_OUTPUT="${j/\/data\//\/output\/}/CC"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
#mkdir -p "$PATH_CC_OUTPUT"
Connectivity_processing "$PATH_CC_OUTPUT" "$PATH_T1_OUTPUT"
echo "----------Connectivity Analysis End"
echo
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
# PET processing
echo "----------PET processing Start"
PATH_PET_INPUT="${path}/pet"
PATH_PET_OUTPUT="${j/\/data\//\/output\/}/pet"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
PATH_CC_OUTPUT="${j/\/data\//\/output\/}/CC"
#mkdir -p "$PATH_PET_OUTPUT"
#cp "${PATH_PET_INPUT}"/* "${PATH_PET_OUTPUT}/"
PET_processing "$PATH_PET_OUTPUT" "$PATH_T1_OUTPUT" "$PATH_CC_OUTPUT"
echo "----------PET processing End"
echo
--MULTILINE-COMMENT--



#<< --MULTILINE-COMMENT--
# Dings suggesttion
echo "----------ROI regressor Start"

PATH_PET_OUTPUT="${j/\/data\//\/output\/}/pet"
PATH_T1_OUTPUT="${j/\/data\//\/output\/}/anat"
PATH_ROI_OUTPUT="${j/\/data\//\/output\/}/ROI"
PATH_RS_OUTPUT="${j/\/data\//\/output\/}/func"
PATH_DWI_OUTPUT="${j/\/data\//\/output\/}/dwi"
#mkdir -p "$PATH_ROI_OUTPUT"

ROI_regressor "$PATH_T1_OUTPUT" "$PATH_PET_OUTPUT" "$PATH_ROI_OUTPUT" "$PATH_RS_OUTPUT" "$PATH_DWI_OUTPUT"
echo "----------ROI regressor End"
#--MULTILINE-COMMENT--


fi
done
fi
done

echo "----------Data Preprocessing End----------"
