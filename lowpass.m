function newdata = lowpass(data,samprate,cutoff)
% Lowpass Filter 
% 
% filt_data = lowpass(data,samprate,cutoff)
%
[B,A] = butter(2,cutoff/(samprate/2));

newdata = filtfilt(B,A,data);


%Uso de la función
%low_pass_data = lowpass(high_pass_data,0.5,0.08); % enter data, sampling rate, cutoff
