close all
clear

cancion = wavread('cancion.wav');
Fs  = 8000; 
N = 100;
Noverlap = round(N/6);

figure
spectrogram(cancion,hanning(N)',Noverlap,4*N,Fs);