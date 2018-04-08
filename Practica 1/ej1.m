clear

%% EJERCICIO 1

f1 = 100;
f2 = 200;
Fs = 500;
Ts = 1/Fs;

A=1;
B=1;

L = 10;

n = 0:L-1;
Xn = A*cos(2*pi*f1*n*Ts) + B*cos(2*pi*f2*n*Ts);

figure
plot(n,Xn)

N = 10;
Fxn = abs(fft(Xn,N));

figure
stem(-Fs/2:Fs/N:Fs/2-Fs/N,Fxn)


%% EJERCICIO 3

N = N*8;
Fxn = abs(fft(Xn,N));

figure
stem(-Fs/2:Fs/N:Fs/2-Fs/N,Fxn)
