addpath('/media/dingzhou/Matlab/NifTI/NIfTI_20140122');

path_subject=strcat('./output/sub-EiMa54/ses-2/func/');
tic
vol4d=load_untouch_nii(char(strcat(path_subject,'merge.nii')));
vol4d_filtrada=vol4d;
Matriz_filtrada=nan(size(vol4d.img));

for x=1:size(vol4d.img,1)
    for y=1:size(vol4d.img,2)
        for z=1:size(vol4d.img,3)
            aux=squeeze(vol4d.img(x,y,z,:)); 
            aux=double(aux); 
            MEAN=mean(aux); 
            STD=std(aux);
            aux=(aux-mean(aux))/std(aux); 
            TR=2.23;%% MODIFY ACCORDINGLY
            fs=1/TR;
            N=length(aux);
            [filtrada]=highpass(aux,fs,0.009);
            [filtrada]=lowpass(filtrada,fs,0.08);
            Matriz_filtrada(x,y,z,:)=filtrada;
            vol4d_filtrada.img(x,y,z,:)=int16(filtrada*STD+MEAN);
        end
    end
end

save(strcat(path_subject, 'Matriz_filtrada_final_filter.mat') , 'Matriz_filtrada');
save_untouch_nii(vol4d_filtrada,char(strcat(path_subject,'merge_filtered.nii')));
toc
