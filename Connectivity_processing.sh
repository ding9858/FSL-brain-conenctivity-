function Connectivity_processing() {

local PATH_CC_OUTPUT="$1"
local PATH_T1_OUTPUT="$2"

<< --MULTILINE-COMMENT--
echo 'Split ATLAS'
for var in {1..120}
do
echo "$var"
fslmaths ${PATH_T1_OUTPUT}/AAL2_to_T1_0p5.nii -thr $var -uthr $var ${PATH_CC_OUTPUT}/roi_$var.nii.gz
fslmaths ${PATH_CC_OUTPUT}/roi_$var.nii.gz -bin ${PATH_CC_OUTPUT}/bin_roi_$var.nii.gz
done;
--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo 'Combining Vermis 1-2 and Vermis 3'
fslmaths ${PATH_CC_OUTPUT}/roi_113.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_114.nii.gz ${PATH_CC_OUTPUT}/bin_roi_113.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_114.nii.gz

echo 'Remove pallidum'
rm ${PATH_CC_OUTPUT}/bin_roi_79.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_80.nii.gz

echo 'Combining Vermis 9 and 10'
fslmaths ${PATH_CC_OUTPUT}/bin_roi_119.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_120.nii.gz ${PATH_CC_OUTPUT}/bin_roi_119.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_120.nii.gz

echo 'Combining cerebellum 8 and 10'
fslmaths ${PATH_CC_OUTPUT}/bin_roi_107.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_111.nii.gz ${PATH_CC_OUTPUT}/bin_roi_107.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_111.nii.gz
fslmaths ${PATH_CC_OUTPUT}/bin_roi_108.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_112.nii.gz ${PATH_CC_OUTPUT}/bin_roi_108.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_112.nii.gz

echo 'Combining cerebellum 3 and cerebellum 4-5'
fslmaths ${PATH_CC_OUTPUT}/bin_roi_99.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_101.nii.gz ${PATH_CC_OUTPUT}/bin_roi_99.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_101.nii.gz
fslmaths ${PATH_CC_OUTPUT}/bin_roi_100.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_102.nii.gz ${PATH_CC_OUTPUT}/bin_roi_100.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_102.nii.gz

echo 'Combining OFC regions'
fslmaths ${PATH_CC_OUTPUT}/bin_roi_25.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_27.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_29.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_31.nii.gz ${PATH_CC_OUTPUT}/bin_roi_25.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_27.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_29.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_31.nii.gz

fslmaths ${PATH_CC_OUTPUT}/bin_roi_26.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_28.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_30.nii.gz -add ${PATH_CC_OUTPUT}/bin_roi_32.nii.gz ${PATH_CC_OUTPUT}/bin_roi_26.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_28.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_30.nii.gz
rm ${PATH_CC_OUTPUT}/bin_roi_32.nii.gz

echo 'Renaming ROIs'
mv ${PATH_CC_OUTPUT}/bin_roi_59.nii.gz ${PATH_CC_OUTPUT}/fusiform_L.nii.gz
mv ${PATH_CC_OUTPUT}/bin_roi_60.nii.gz ${PATH_CC_OUTPUT}/fusiform_R.nii.gz

for a in {33..58}
do
aux=6
b=`expr $a - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$a.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$b.nii.gz
done;

for c in {61..78}
do
aux=8
d=`expr $c - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$c.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$d.nii.gz
done;

for e in {81..82}
do
aux=10
f=`expr $e - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$e.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$f.nii.gz
done;

mv ${PATH_CC_OUTPUT}/fusiform_L.nii.gz ${PATH_CC_OUTPUT}/bin_roi_73.nii.gz
mv ${PATH_CC_OUTPUT}/fusiform_R.nii.gz ${PATH_CC_OUTPUT}/bin_roi_74.nii.gz

for g in {83..100}
do
aux=8
h=`expr $g - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$g.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$h.nii.gz
done;

for k in {103..110}
do
aux=10
l=`expr $k - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$k.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$l.nii.gz
done;

mv ${PATH_CC_OUTPUT}/bin_roi_113.nii.gz ${PATH_CC_OUTPUT}/bin_roi_101.nii.gz

for m in {115..119}
do
aux=13
n=`expr $m - $aux`
mv ${PATH_CC_OUTPUT}/bin_roi_$m.nii.gz ${PATH_CC_OUTPUT}/bin_roi_$n.nii.gz
done
--MULTILINE-COMMENT--



<< --MULTILINE-COMMENT--
fslmaths ${PATH_T1_OUTPUT}/GM.nii -thr 0.5 ${PATH_T1_OUTPUT}/GM_0.5.nii

echo "ROI Volume/Density extraction"
echo "a: Thresholding GM probability map"
rm ${PATH_CC_OUTPUT}/density_roi_*.nii.gz
rm ${PATH_CC_OUTPUT}/GM_density_wanted.txt
rm ${PATH_CC_OUTPUT}/GM_density_detected.txt
rm ${PATH_CC_OUTPUT}/GM_volumes_detected.txt
rm ${PATH_CC_OUTPUT}/GM_volumes_wanted.txt

touch ${PATH_CC_OUTPUT}/GM_density_wanted.txt
touch ${PATH_CC_OUTPUT}/GM_density_detected.txt
touch ${PATH_CC_OUTPUT}/GM_volumes_detected.txt
touch ${PATH_CC_OUTPUT}/GM_volumes_wanted.txt
echo 'b: GM density'
for var in {1..106}
do
echo "$var"
fslmaths ${PATH_CC_OUTPUT}/bin_roi_$var.nii.gz -mul  ${PATH_T1_OUTPUT}/GM_0.5.nii.gz ${PATH_CC_OUTPUT}/density_roi_$var.nii.gz
fslstats ${PATH_CC_OUTPUT}/density_roi_$var.nii.gz -M >> ${PATH_CC_OUTPUT}/GM_density_detected.txt;


echo 'c: Total density'
fslmaths ${PATH_CC_OUTPUT}/AAL2_bin_roi_$var.nii.gz -mul ${PATH_T1_OUTPUT}/GM_0.5.nii.gz ${PATH_CC_OUTPUT}/density_AAL2_roi_$var.nii;
fslstats ${PATH_CC_OUTPUT}/density_AAL2_roi_$var.nii -M >> ${PATH_CC_OUTPUT}/GM_density_wanted.txt;
done;



echo 'GM Volume'
for var in {1..106}
do
echo "$var"
fslstats ${PATH_CC_OUTPUT}/density_roi_$var.nii.gz -V >> ${PATH_CC_OUTPUT}/GM_volumes_detected.txt;

echo 'd: Total Volume'
fslstats ${PATH_CC_OUTPUT}/density_AAL2_roi_$var.nii.gz -V >> ${PATH_CC_OUTPUT}/GM_volumes_wanted.txt;

done;
--MULTILINE-COMMENT--


#<< --MULTILINE-COMMENT--
echo "Center of gravity"

rm ${PATH_CC_OUTPUT}/Centers_of_gravity_c.txt;
rm ${PATH_CC_OUTPUT}/Centers_of_gravity_AAL2.txt;

for var in {1..106}
do
echo "$var"
fslstats ${PATH_CC_OUTPUT}/bin_roi_$var.nii.gz -c >> ${PATH_CC_OUTPUT}/Centers_of_gravity_c.txt;
fslstats ${PATH_CC_OUTPUT}/AAL2_bin_roi_$var.nii.gz -c >> ${PATH_CC_OUTPUT}/Centers_of_gravity_AAL2.txt;
done;
#--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--

rm ${PATH_CC_OUTPUT}/GM_volumes_regress.txt
touch ${PATH_CC_OUTPUT}/GM_volumes_regress.txt
echo "Step 5.b: Total GMV regression"
fsl_glm -i ${PATH_CC_OUTPUT}/GM_volumes_wanted.txt -d ${PATH_CC_OUTPUT}/GM_volumes_detected.txt --out_res=${PATH_CC_OUTPUT}/GM_volumes_regress.txt

--MULTILINE-COMMENT--



}
