close all
clear 

Fo = 125;
F = [660 1720 2410 3500 4500];
sigma = [60 100 120 175 250];

T = 1/16000;
Fs = 1/T;

duracion = 2; % en segundos

puntos_fft = 200e3;

pulsos = zeros(1,duracion/T);
pulsos(1:(1/Fo)/T:length(pulsos)) = 1;

coeficientes = @(Fk,sigmak) ([1 -2*exp(-2*pi*sigmak*T)*cos(2*pi*Fk*T) exp(-4*pi*sigmak*T)]);

ventana = 25e-3;
ancho = ventana * Fs;

liftering = 51; % tomo solo los primeros 50 elementos

% sound(pulsos,Fs);

% Filtro tracto vocal
senial = pulsos;
filtro = ones(puntos_fft,1);
for k = 1:length(F)
    senial = filter(1,coeficientes(F(k), sigma(k)),senial);
    filtro = filtro .* abs(freqz(1,coeficientes(F(k), sigma(k)), length(filtro), 'whole'));
end
senial_tracto_vocal = senial;

% sound(senial,Fs);

% Filtro radiacion labial
gamma = 0.96;
senial = filter([1 -gamma], 1, senial);
filtro = filtro .* abs(freqz([1 -gamma], 1, puntos_fft, 'whole'));

senial_labial = senial;

figure
stem(pulsos)
hold on
plot(senial_tracto_vocal,'r');
hold on
plot(senial_labial,'g');
legend('pulsos','tracto vocal','radiacion labial');

cepstrum = ifft(log(abs(fft(senial, puntos_fft)) + 1));

figure
plot(cepstrum);

% sound(cepstrum,Fs);


cepstrum(liftering:end-liftering+1) = 0;

figure
plot(cepstrum);

salida = exp(abs(fft(cepstrum)))-1;

frec = 0:Fs/length(salida):Fs - Fs/length(salida);
% frec = frec*1e-3; %lo paso a khz
figure
plot(frec,salida,'b')
hold on
plot(frec,filtro,'r')
xlabel('Frecuencia [Hz]');


cepstrum_cheto = rceps(senial, puntos_fft);

figure
plot(cepstrum)
hold on
plot(cepstrum_cheto, 'r')
xlim([1 50])