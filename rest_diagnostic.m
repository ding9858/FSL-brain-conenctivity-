folder=strcat('./output/sub-EiMa54/ses-2/func/');
name=strcat(folder,'resting.nii');
name=char(name);
name2=strcat(folder,'DIAGNOSTIC');
name2=char(name2);
[td, globals, slicediff, imgs] = tsdiffana(name);
saveas(gcf,name2, 'jpg');