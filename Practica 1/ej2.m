clear
close all

load guia1_files.mat
Fs = 1000;

%% Y1

N = length(y1);
Fy1 = abs(fft(y1,N)/length(y2));

figure
stem(-Fs/2:Fs/N:Fs/2-Fs/N,Fy1)

%% Y2

N = length(y2);
Fy2 = abs(fft(y2,N))/length(y2);

figure
stem(-Fs/2:Fs/N:Fs/2-Fs/N,Fy2)

%% expectrogramas

N = 100;
Noverlap = round(N/6);
% Noverlap  = 0;
figure
spectrogram(y1,hanning(N)',Noverlap,length(y1),Fs)

figure
spectrogram(y2,hanning(N)',Noverlap,length(y2),Fs)

