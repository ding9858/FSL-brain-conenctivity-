nROIs=100;

path_subject = strcat('./output/sub-EiMa54/ses-2/func/Slice/');

for k=1:nROIs
    new_path = sprintf('%smerge_regress_no_demean_AAL2_roi_%d.txt', path_subject, k);
    %new_path=strcat(path_subject,'just_filter_media_AAL2_roi_',k,'.txt');
    disp(['Current Path: ' new_path]);
    A(:,k)=importdata(new_path);
end

%Pearson

[Pearson_matrix,p_matrix]=corrcoef(A);

%Removing self-correlations

for k=1:nROIs
    Pearson_matrix(k,k)=0;
end

%Fisher transform

F_Pearson=zeros(nROIs,nROIs);
