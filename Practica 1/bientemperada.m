clear all

%simbolo = {'do', 're', 'mi', 'fa','sol','la','sib','doagudo'};
f = 440*[2^(-9/12) 2^(-7/12) 2^(-5/12) 2^(-4/12) 2^(-2/12) 1 2^(2/12) 2^(3/12)];
Fs  = 8000;       

% La unidad de tiempo es la corchea, que dura aprox. 100mseg. (los silencios entre notas duran 20
% mseg)
Nredonda = 800*8.8;
Nblanca = 800*3.8;      
Nnegra = 800*1.8;
Nnegrapunt = 800*2.8;
Ncorchea = 800*0.8;
duraciones = [Nredonda Nblanca Nnegrapunt Nnegra Ncorchea];

bientemp = [ 1 1 2 1 4 3 1 1 2 1 5 4 1 1 8 6 4 4 3 2];
tempo    = [ 3 5 2 2 2 1 3 5 2 2 2 1 3 5 2 2 3 5 2 2];
amplitudes = [1 1.2 1/2 1/4 1/8 1/16 1/32];
%amplitudes = [0 0 1 0.1 0 0 0];
cancion = [];

for n=1:length(bientemp)
    nota = sum(diag(amplitudes)*sin([1;2;3;4;5;6;7]*f((bientemp(n)))*2*pi*(0:(duraciones(tempo(n))-1))/Fs));
    cancion = [cancion nota zeros(1,160)];
end

% wavwrite(cancion/max(abs(cancion))*0.95,Fs, 'cancion.wav');
audiowrite('cancion_script.wav', cancion/max(abs(cancion))*0.95,Fs)

