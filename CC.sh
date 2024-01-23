for i in 'BaIm63' 'BaMa67' 'BaNe67' 'BeMa61' 'BoAn58' 'BrGe60' 'BuCh65' 'DiPe66' 'EiMa54' 'EmYv57' 'FlAn61' 'HaBu57' 'HaEd67' 'HaGa61' 'HaJo58' 'HaUl67' 'HeRo67' 'HeSu65' 'HoAl57' 'HoIn59' 'HoSi61' 'JaGr64' 'JeBu65' 'JuUl58' 'KiMi62' 'LeEr59' 'LiIn57' 'MaAn64' 'MaAn68' 'MiGu57' 'NeEv66' 'NeNo60' 'NiAx57' 'NiMi63' 'NoBe65' 'NoHa55' 'OsGe59' 'PaSi67' 'PfRi58' 'PiMa64' 'PrMa55' 'RaHa58' 'RaRe65' 'RuEl64' 'RuNo56' 'SaEd65' 'ScMa63' 'SaMo64' 'ScAn67' 'ScAr63' 'ScJo55' 'ScRe61' 'SeAn63' 'SeSa61' 'SkJu61' 'SpHe57' 'StCa55' 'TeMi67' 'WaGu55' 'WeMa64' 'WeSt57' 'WiEl57' 'ZaGa64' 'ZiJe65' 
do
echo "$i"

for j in "FIRST_SESSION" "SECOND_SESSION" 
do
echo "$j"

#mkdir /data_tina/Aldana/SUBJECTS/$i/$j/CC

#<< --MULTILINE-COMMENT--

echo 'Split ATLAS'
for var in {1..120}
do
echo "$var"
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/PROCESSING/TRACTfiles/AAL2_to_T1_0p5.nii -thr $var -uthr $var /data_tina/Aldana/SUBJECTS/$i/$j/CC/roi_$var.nii.gz
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/roi_$var.nii.gz -bin /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$var.nii.gz 
done;
#--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo 'Combining Vermis 1-2 and Vermis 3'
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/roi_113.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_114.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_113.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_114.nii.gz

echo 'Remove pallidum'
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_79.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_80.nii.gz

echo 'Combining Vermis 9 and 10'
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_119.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_120.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_119.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_120.nii.gz 

echo 'Combining cerebellum 8 and 10'
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_107.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_111.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_107.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_111.nii.gz 
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_108.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_112.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_108.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_112.nii.gz 

echo 'Combining cerebellum 3 and cerebellum 4-5'
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_99.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_101.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_99.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_101.nii.gz 
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_100.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_102.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_100.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_102.nii.gz 

echo 'Combining OFC regions'
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_25.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_27.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_29.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_31.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_25.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_27.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_29.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_31.nii.gz
 
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_26.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_28.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_30.nii.gz -add /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_32.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_26.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_28.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_30.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_32.nii.gz

echo 'Renaming ROIs' 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_59.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/fusiform_L.nii.gz
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_60.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/fusiform_R.nii.gz

for a in {33..58}
do
aux=6
b=`expr $a - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$a.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$b.nii.gz
done;

for c in {61..78}
do
aux=8
d=`expr $c - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$c.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$d.nii.gz
done;

for e in {81..82}
do
aux=10
f=`expr $e - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$e.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$f.nii.gz
done;

mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/fusiform_L.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_73.nii.gz
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/fusiform_R.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_74.nii.gz

for g in {83..100}
do
aux=8
h=`expr $g - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$g.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$h.nii.gz
done;

for k in {103..110}
do
aux=10
l=`expr $k - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$k.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$l.nii.gz
done;

mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_113.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_101.nii.gz

for m in {115..119}
do
aux=13
n=`expr $m - $aux` 
mv /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$m.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$n.nii.gz
done
--MULTILINE-COMMENT--

<< --MULTILINE-COMMENT--
echo "ROI Volume/Density extraction"

#echo "a: Thresholding GM probability map"
#fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/T1/GM_mask.nii.gz -thr 0.5  /data_tina/Aldana/SUBJECTS/$i/$j/T1/GM_0.5.nii.gz

rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_roi_*.nii.gz
rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_density.txt;

echo 'b: GM density'
for var in {1..106}
do
echo "$var"
fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$var.nii.gz -mul  /data_tina/Aldana/SUBJECTS/$i/$j/T1/GM_0.5.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_roi_$var.nii.gz
fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_roi_$var.nii.gz -M >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_density.txt;
done;

echo 'c: Total density'
#fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/PROCESSING/TRACTfiles/AAL2_to_T1_0p5.nii -bin /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_AAL2_to_T1_0p5.nii.gz;
#fslmaths /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_AAL2_to_T1_0p5.nii -mul /data_tina/Aldana/SUBJECTS/$i/$j/T1/GM_0.5.nii.gz /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_AAL2.nii;
#fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_AAL2.nii -M >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_density.txt;

rm /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_volumes.txt;
echo 'GM Volume'
for var in {1..106}
do
echo "$var"
fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/density_roi_$var.nii.gz -V >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_volumes.txt;
done;

echo 'd: Total Volume'
fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_AAL2_to_T1_0p5.nii.gz -V >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/GM_volumes.txt;

--MULTILINE-COMMENT--



#<< --MULTILINE-COMMENT--
echo "Step 5.b: Total GMV regression"

fsl_glm -i /data_tina/Aldana/SUBJECTS/FIRST_SESSION_real_GM_volumes.txt -d /data_tina/Aldana/SUBJECTS/FIRST_SESSION_total_real_GM_volumes.txt --out_res=/data_tina/Aldana/SUBJECTS/FIRST_SESSION_real_GM_volumes_regress.txt

#fsl_glm -i /data_tina/Aldana/SUBJECTS/SECOND_SESSION_real_GM_volumes.txt -d /data_tina/Aldana/SUBJECTS/SECOND_SESSION_total_real_GM_volumes.txt --out_res=/data_tina/Aldana/SUBJECTS/SECOND_SESSION_real_GM_volumes_regress.txt

#--MULTILINE-COMMENT--


<< --MULTILINE-COMMENT--
echo "Center of gravity"
for var in {1..106}
do
echo "$var"
fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$var.nii.gz -c >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/Centers_of_gravity_c.txt;
fslstats /data_tina/Aldana/SUBJECTS/$i/$j/CC/bin_roi_$var.nii.gz -C >> /data_tina/Aldana/SUBJECTS/$i/$j/CC/Centers_of_gravity_C.txt;
done;

--MULTILINE-COMMENT--

done;
done;







































