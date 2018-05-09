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
resultados_test = [];
archivos = dir(fullfile('data','*.txt'));
for x = 1:length(archivos)
    
    archivo_actual = fullfile('data', archivos(x).name);    
    
    formantes_actuales = importdata(archivo_actual)';
    formantes_actuales = formantes_actuales(formantes_utilizados,:);
    formantes_actuales = formantes_actuales(:,randperm(length(formantes_actuales)));
    
    original{x} = formantes_actuales;
    
    bootstrap_set{x} = formantes_actuales(:,1:bootstrap);
    train_set = [train_set formantes_actuales(:,bootstrap+1:bootstrap+train)];
    test_set = [test_set formantes_actuales(:,bootstrap+train+1:end)];
    resultados_test = [resultados_test ones(1,length(original{x})-train-bootstrap).*x];
end

%% OBTENGO LA MEDIA DE LOS ELEMENTOS DEL BOOTSTRAP

for x = 1:length(bootstrap_set)
    parametro.media = calcular_media(bootstrap_set{x});
    parametro.varianza = calcular_varianza(bootstrap_set{x},parametro.media);
    parametro.pi = length(bootstrap_set{x})/(bootstrap*length(bootstrap_set));
    parametros(x) = parametro;
end

%% INICIO EL ENTRENAMIENTO

TOLERANCIA = 1e-3;
likelihood = [];
while true

    %% OBTENGO GAMMA

    for i = 1:size(train_set, 2)
        Gamma(i,:) = calcular_gamma(parametros, train_set(:,i));
    end

    %% RECALCULO PARAMETROS

    for k = 1:length(parametros)

        suma_gamma = sum(Gamma(:,k));

        % MEDIA
        parametros(k).media = sum(Gamma(:,k).*train_set')'/suma_gamma;

        % VARIANZA
        numerador = 0;
        for i = 1:size(train_set,2)

            aux = (train_set(:,i) - parametros(k).media);
            aux = aux * aux';
            numerador = numerador + Gamma(i,k) * aux;

        end

        parametros(k).varianza = numerador/suma_gamma;

        % PI
        parametros(k).pi = suma_gamma/sum(sum(Gamma));

    end

    %% LIKELIHOOD

    LL = 0;
    for i = 1:size(train_set,2)
        aux = 0;
        for k = 1:length(parametros)    
            aux = aux + mvnpdf(train_set(:,i),parametros(k).media,parametros(k).varianza) * parametros(k).pi;
        end
        LL = LL + log(aux);
    end

    likelihood = [likelihood LL];
    
    if length(likelihood) > 1 && abs(likelihood(end) - likelihood(end-1)) < TOLERANCIA
        break
    end

end

figure
plot(likelihood)

%% CLASIFICO

for x = 1:length(bootstrap_set)
    clasificacion_train{x} = [];
    clasificacion_test{x} = [];
end

for i = 1:size(train_set, 2)
    Gamma = calcular_gamma(parametros, train_set(:,i));
    
    clase = find(max(Gamma) == Gamma);
    clasificacion_train{clase}(:,end+1) = train_set(:,i);
end

errores = 0;

for i = 1:size(test_set,2)
    Gamma = calcular_gamma(parametros, test_set(:,i));
    
    clase = find(max(Gamma) == Gamma);
    clasificacion_test{clase}(:,end+1) = test_set(:,i);
    if clase ~= resultados_test(i)
        errores = errores + 1;
    end
end


leyenda = {};
figure
hold on;

for x = 1:length(bootstrap_set)
   
    plot(original{x}(1,:),original{x}(2,:), [colores(x) '.'], 'linewidth',3)
    leyenda = [leyenda ['original ' num2str(x)]];
    
    plot(clasificacion_train{x}(1,:),clasificacion_train{x}(2,:), [colores(x) 'o'])
    leyenda = [leyenda ['train set ' num2str(x)]];
    
    plot(clasificacion_test{x}(1,:),clasificacion_test{x}(2,:), [colores(x) '^'])
    leyenda = [leyenda ['test set ' num2str(x)]];
% 
%     plot(parametros(x).media(1), parametros(x).media(2), '+k','linewidth',2);
%     leyenda = [leyenda ['media ' num2str(x)]];
    
end

legend(leyenda, 'Location','best');

%% ERRORES DETECTADOS

disp(['Errores = ' num2str(errores)]);

%% GRAFICO USANDO LOS GAMMA COMO CODIGO DE COLORES


figure
for i = 1:size(train_set,2)
    Gamma = calcular_gamma(parametros, train_set(:,i));
    plot(train_set(1,i), train_set(2,i),'o','color',Gamma)
    hold on
end

for i = 1:size(test_set,2)
    Gamma = calcular_gamma(parametros, test_set(:,i));
    plot(test_set(1,i), test_set(2,i),'^','color',Gamma)
    hold on
end