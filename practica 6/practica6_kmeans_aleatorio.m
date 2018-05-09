close all
clear
clc

colores = 'rgbymc';
formantes_utilizados = 1:2;

%% ALEATORIO 
train = 40; % cantidad de formantes utilizados para el entrenamiento

train_set = [];
test_set = [];
resultados_test = [];

archivos = dir(fullfile('data','*.txt'));
for x = 1:length(archivos)
    
    archivo_actual = fullfile('data', archivos(x).name);    
    
    formantes_actuales = importdata(archivo_actual)';
    formantes_actuales = formantes_actuales(formantes_utilizados,:);
    formantes_actuales = formantes_actuales(:,randperm(length(formantes_actuales)));
    
    original{x} = formantes_actuales;
    
    train_set = [train_set formantes_actuales(:,1:train)];
    test_set = [test_set formantes_actuales(:,train+1:end)];
    resultados_test = [resultados_test ones(1,length(original{x})-train).*x];

end

%% OBTENGO LOS PARAMETROS EN BASE A UNA CLASIFICACION PREVIA ALEATORIA

media_central = calcular_media(train_set);

continuar = true;
while continuar


    for x = 1:length(archivos)
        angulos_limites(x) =(rand*2-1)*pi;
    end
    angulos_limites = sort(angulos_limites);

    % PRIMER CLASIFICACION DEL TRAINSET

    clasificacion = clasificar_polar(angulos_limites, media_central, train_set);

    % si esta vacio un subespacio repito 
    continuar = false;
    for x = 1:length(clasificacion)
        if isempty(clasificacion{x})
            continuar = true;
        end
    end
    
end

for x = 1:length(clasificacion)
    medias(:,x) = calcular_media(clasificacion{x});
end

graficar_clasificacion(colores, clasificacion, medias);


%% INICIO DEL APRENDIZAJE

% AGRUPO LOS TRAINSET A LAS MEDIAS MAS CERCANAS

tolerancia = 1e-3;

distorsiones(1) = calcular_distorsion(medias, clasificacion);

n = 1;
continuar = true;
while continuar
    n = n + 1;
    clasificacion = clasificacion_euclidea(medias, train_set);

    for x = 1:size(medias,2)
        medias(:,x) = calcular_media(clasificacion{x});
    end
    
    distorsiones(n) = calcular_distorsion(medias, clasificacion);
   
    if abs(distorsiones(end) - distorsiones(end-1)) < tolerancia
        continuar = false;
    end
   
    graficar_clasificacion(colores, clasificacion, medias)
    
end

%% DISTORSIÓN

figure
plot(distorsiones(2:end))

% CALCULO EL RESTO DE LOS PARAMETROS
for x = 1:size(medias,2)
    parametro.media = medias(:,x);
    parametro.varianza = calcular_varianza(clasificacion{x},parametro.media);
    parametro.pi = length(clasificacion{x})/(train*length(clasificacion));
    parametros(x) = parametro;
end

%% REORDENO LAS CLASES PARA QUE COINCIDAN CON LOS ARCHIVOS

for y = 1:length(parametros)
    media = calcular_media(test_set(:,y*10-9:y*10));
    for x = 1:length(parametros)
        error(x) = norm(parametros(x).media - media);
    end    
    nuevo_orden(y) = find(min(error) == error);
end
parametros = parametros(nuevo_orden);

%% FUNCION DISCRIMINANTE

for k = 1:length(parametros)
    g{k} = @(x) (-1/2) * log( abs( det( parametros(k).varianza ) ) ) + ...
        (-1/2) * (x-parametros(k).media)' * parametros(k).varianza^-1 * (x-parametros(k).media) + ...
        log(parametros(k).pi);
end

%% INICIO DEL TEST

clasificacion_train = clasificar_discriminante(g, train_set);
[clasificacion_test, errores] = clasificar_discriminante(g, test_set, resultados_test);

leyenda = {};
figure
hold on;
for x = 1:length(parametros)
    
    plot(original{x}(1,:),original{x}(2,:), [colores(x) '.'], 'linewidth',3)
    leyenda = [leyenda ['original ' num2str(x)]];
    
    if ~isempty(clasificacion_train{x})
        plot(clasificacion_train{x}(1,:),clasificacion_train{x}(2,:), [colores(x) 'o'])        
        leyenda = [leyenda ['train set ' num2str(x)]];
    end
    
    if ~isempty(clasificacion_test{x})
        plot(clasificacion_test{x}(1,:),clasificacion_test{x}(2,:), [colores(x) '^'])
        leyenda = [leyenda ['test set ' num2str(x)]];
    end

%     plot(parametros(x).media(1), parametros(x).media(2), '+k');
%     leyenda = [leyenda ['media ' num2str(x)]];

end

legend(leyenda, 'Location','best');

disp(['Errores = ' num2str(errores)]);