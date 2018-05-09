close all
clear
clc

colores = 'rgbymc';
formantes_utilizados = 1:2;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%% LDA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% EXTRACCION DE DATOS

train = 40; % cantidad de formantes utilizados para el entrenamiento

archivos = dir(fullfile('data','*.txt'));
train_set = {};
test_set = {};
for x = 1:length(archivos)
    
    archivo_actual = fullfile('data', archivos(x).name);    
    
    formantes_actuales = importdata(archivo_actual);
    formantes_actuales = formantes_actuales(:,formantes_utilizados)';    
    
    train_set = [train_set formantes_actuales(:,1:train)];
    test_set = [test_set formantes_actuales(:,train+1:end)];
end

%% CALCULO DE LAS MEDIAS Y VARIANZAS
for x = 1:length(train_set)
    parametro.media = calcular_media(train_set{x});
    parametro.varianza = calcular_varianza(train_set{x},parametro.media);
    parametros(x) = parametro;
end

%% Promedio las 3 varianzas para obtener una sola
varianza = 0;
for x = 1:length(parametros)
    varianza = varianza + parametros(x).varianza;
end
varianza = varianza./length(parametros);

% Actualizo la varianza de cada clase
for x =1:length(parametros)
    parametros(x).varianza = varianza;
end

%% GRAFICO DE LOS PUNTOS DE TRAIN Y TESTEO Y CURVAS DE NIVEL, SIN CLASIFICAR

leyenda = {};

% OBTENGO LA ELIPSE
t = 0:0.01:2*pi;
y =  [cos(t') sin(t')];
elipse = abs(chol(varianza))*y';

figure
hold on

for x = 1:length(train_set)

    elipse_corrida = elipse + parametros(x).media;
    
    plot(train_set{x}(1,:),train_set{x}(2,:), [colores(x) 'o']) % train
    plot(test_set{x}(1,:),test_set{x}(2,:), [colores(x) '*']) % test
    plot(elipse_corrida(1,:),elipse_corrida(2,:), colores(x)) %

    leyenda = [leyenda ['train ' archivos(x).name]];
    leyenda = [leyenda ['test ' archivos(x).name]];
    leyenda = [leyenda ['contorno ' archivos(x).name]];
end

legend(leyenda,'location','southeast');

%% CALCULO DE LA FUNCION DE CLASIFICACION

% Reagrupo los formantes en una sola matriz
formantes_totales = [];
clases = [];
for x = 1:length(train_set)
    formantes_totales = [formantes_totales train_set{x}];
    formantes_totales = [formantes_totales test_set{x}];
    aux  = ones(1,length(train_set{x})+length(test_set{x}))*x;
    clases = [clases aux];
end

% Obtengo la funcion discriminante de cada clase
for k = 1:length(parametros)
    Xok = parametros(k).media' * parametros(k).varianza^-1 * parametros(k).media;
    Vok = parametros(k).varianza^-1 * parametros(k).media;
    g{k} = @(x) (-1/2)*Xok + Vok' * x + log(1/length(parametros));
end

% inicializo la celda de clasificacion
for x = 1:length(parametros)
    clasificacion{x} = [];
end

errores = 0;
for k = 1:size(formantes_totales,2)
    
    formante_actual = formantes_totales(:,k);
    
    for j = 1:length(g)
        resultados(j) = g{j}(formante_actual);
    end
    clase = find(max(resultados)==resultados);
    if clase ~= clases(k)
        errores = errores + 1;
    end
    clasificacion{clase}(:,end+1) = formante_actual;
end

leyenda = {};
figure
for x = 1:length(clasificacion)
    
    plot(clasificacion{x}(1,:),clasificacion{x}(2,:), [colores(x) 'o'])
    hold on
    leyenda = [leyenda archivos(x).name];
end
legend(leyenda, 'Location','southeast');

error_porcentaje = 100*errores / length(clases);

disp(['Error = ' num2str(error_porcentaje) '%' ])
