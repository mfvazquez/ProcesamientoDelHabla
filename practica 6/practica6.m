close all
clear

archivos = dir(fullfile('data','*.txt'));

formantes_utilizados = 1:2;
datos_entrenar = 40;

%% Se extraen los datos y se calculan los parámetros de cada archivo
datos = [];
for x = 1:length(archivos)
    
    archivo_actual = fullfile(archivos(x).folder, archivos(x).name);    
    
    formantes = importdata(archivo_actual);
    formantes = formantes(:,formantes_utilizados);    
    
    letra = archivos(x).name(1);
    
    media = 0;
    for y = 1:datos_entrenar
        media = media + formantes(y,:);
    end
    media = media/datos_entrenar;
    
    varianza = 0;
    for y = 1:datos_entrenar
        X = formantes(y,:);
        varianza = varianza + (X-media)'*(X-media);
    end
    varianza = varianza/datos_entrenar;
        

    datos_actuales.letra = letra;
    datos_actuales.media = media;
    datos_actuales.varianza = varianza;
    datos_actuales.formantes = formantes;

    datos = [datos datos_actuales];
    
end

%% Promedio las 3 varianzas para obtener una sola
varianza = 0;
for x = 1:length(datos)
    varianza = varianza + datos(x).varianza;
end
varianza = varianza/length(datos);

%% Dibujo los puntos de cada archivo
leyenda = {};
colores = 'brg';
figure
for x = 1:length(datos)
      
    plot(datos(x).formantes(1:datos_entrenar,1), datos(x).formantes(1:datos_entrenar,2),[colores(x) 'o'])
    hold on;
    plot(datos(x).formantes(datos_entrenar+1:end,1), datos(x).formantes(datos_entrenar+1:end,2),[colores(x) '*'])
    leyenda = [leyenda [datos(x).letra ' train']];
    leyenda = [leyenda [datos(x).letra ' test']];
end

%% Elipses
t = 0:0.01:2*pi;
y =  [cos(t') sin(t')];
elipse = abs(chol(varianza))*y';

for x = 1:length(datos)
    elipse_corrida = elipse' + datos(x).media;
    
    plot(elipse_corrida(:,1),elipse_corrida(:,2), colores(x));
    hold on;
    
    leyenda = [leyenda [datos(x).letra ' contorno']];
end

legend(leyenda,'location','southeast');


