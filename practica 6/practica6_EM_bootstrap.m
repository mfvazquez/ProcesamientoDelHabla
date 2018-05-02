close all
clear
clc

colores = 'rgbymc';
formantes_utilizados = 1:2;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% EM BOOTSTRAP %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

bootstrap = 5;
train = 35; % cantidad de formantes utilizados para el entrenamiento

train_set = [];
test_set = [];
archivos = dir(fullfile('data','*.txt'));
for x = 1:length(archivos)
    
    archivo_actual = fullfile('data', archivos(x).name);    
    
    formantes_actuales = importdata(archivo_actual)';
    formantes_actuales = formantes_actuales(formantes_utilizados,:);
    formantes_actuales = formantes_actuales(:,randperm(length(formantes_actuales)));
    
    bootstrap_set{x} = formantes_actuales(:,1:bootstrap);
    train_set = [train_set formantes_actuales(:,bootstrap+1:bootstrap+train)];
    test_set = [test_set formantes_actuales(:,bootstrap+train+1:end)];
end

%% OBTENGO LA MEDIA DE LOS ELEMENTOS DEL BOOTSTRAP

for x = 1:length(bootstrap_set)
    parametro.media = calcular_media(bootstrap_set{x});
    parametro.varianza = calcular_varianza(bootstrap_set{x},parametro.media);
    parametro.pi = length(bootstrap_set{x})/(bootstrap*length(bootstrap_set));
    parametros(x) = parametro;
end

for x = 1:length(bootstrap_set)
    clasificacion{x} = [];
end

for i = 1:length(train_set)
    
    for k = 1:length(bootstrap_set)    
        Gamma(k) = mvnpdf(train_set(:,i),parametros(k).media,parametros(k).varianza) * parametros(k).pi;
    end        
    Gamma = Gamma./sum(Gamma);
    
    clase = find(Gamma == max(Gamma));
    clasificacion{clase}(:,end+1) = train_set(:,i);
    
end

for k = 1:length(clasificacion)
    
    numerador = 0;
    denominador = 0;
    for i = 1:length(train_set)
        
        for c = 1:length(casificacion)
            Gamma(k) = mvnpdf(train_set(:,i),parametros(k).media,parametros(k).varianza) * parametros(k).pi;
        end
        
        numerador = numerador 
    end
    
end
