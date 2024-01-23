path_subject=strcat('./output/sub-EiMa54/ses-2/func/');

csf=load(char(strcat(path_subject,'media_CSF_0p5.txt')));
wm=load(char(strcat(path_subject,'media_WM_0p5.txt')));
mov=load(char(strcat(path_subject,'media_AAL2_0p5.txt')));

size(mov);
%The following correction is implemented to take into account that
%we choose the volume 104 as a reference in the SPM realignment.
mov_correct=zeros(size(mov));
mov_correct(1:104,:)=mov(2:105,:);
mov_correct(105,:)=mov(1,:);
mov_correct(106:209,:)=mov(106:209,:);
csf_wm_mov=[csf,wm,mov];

archivo = fopen(char(strcat(path_subject,'csf_wm_mov_regressors.mat')),'wt');

   for k = 1:209
        fprintf(archivo,'%g\t',csf_wm_mov(k,:));
        fprintf(archivo,'\n');
    end
    fclose(archivo);
