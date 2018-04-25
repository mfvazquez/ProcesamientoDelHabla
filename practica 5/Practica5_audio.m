close all
clear 

[audio, Fs] = audioread('fantasia.wav');

puntos_fft = 200e3;


ventana = 25e-3;
ancho = ventana * Fs;


liftering = 51; % tomo solo los primeros 50 elementos

paso = 10e-3;
inicios = 1:paso*Fs:length(audio)-ancho;

%% Calculo anterior sobre toda la señal

for x = 1:length(inicios)

    S = audio(inicios(x):inicios(x)+ancho-1);
    cepstrum = ifft(log(abs(fft(S, length(S)*2)) + 1));
    cepstrum(liftering:end-liftering+1) = 0;
    espectro(:,x) = abs(fft(cepstrum));

end
   

t = (inicios-1)/Fs;
f = 0:Fs/size(espectro,1):Fs - Fs/size(espectro,1);

figure
surf(t,f, espectro)
colorbar
colormap jet
shading interp
set(gca,'xlim',[0 t(end)], 'ylim', [0 6e3]);
view(2)
xlabel('Tiempo [seg]')
ylabel('Frecuencia [kHz]')

