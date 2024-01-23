% newdata = highpass(data,samprate,cutoff)
function newdata = highpass(data,samprate,cutoff) %function [y1,...,yN] = myfun(x1,...,xM) declares a function named myfun that accepts inputs x1,...,xM and returns outputs y1,...,yN

[B,A] = butter(2,cutoff/(samprate/2),'high'); %[b,a] = butter(n,Wn,ftype)

[r,c] = size(data);

for i=1:c
	newdata(:,i) = filtfilt(B,A,data(:,i));
end;

%Uso de la función
%high_pass_data = highpass(serie_norm,0.5,0.009); % enter data, sampling rate, cutoff

