%% Práctica 7
% Vázquez Matías - 
% Padron:91523 - 
% |mfvazquezfiuba@gmail.com|

close all
clear
clc

addpath('lib');

inic_hmm

%% Inicialición de valores iniciales
% Utilizando la media y varianza de hmm4 y la matriz de transición definida
% genero una secuencia x que tenga al menos 100 puntos en total y al menos
% 15 en cada clase. Luego calculo la media y varianza total de esa
% secuencia para utilizarla como valores iniciales para todas las clases.

means = hmm4.means;
vars = hmm4.vars;
trans = [0   1   0   0   0  ;...
         0   0.5 0.5 0   0  ;...
         0   0   0.5 0.5 0  ;...
         0   0   0   0.5 0.5;...
         0   0   0   0   1  ];
trans(trans<1e-100) = 1e-100;

continuar = true;
while continuar
    continuar = false;
    [x,stateSeq] = genhmm(hmm4);
    
    if length(x) < 100
        continuar = true;
        continue
    end

    for z = 2:length(hmm4.means)-1
        if sum(stateSeq == z) < 15            
            continuar = true;
        end
    end
        
end
train_set = x';

media_inicial = calcular_media(x');
means(2:end-1) = {media_inicial};

varianza_inicial = calcular_varianza(x',media_inicial);
vars(2:end-1) = {varianza_inicial};

%% Entrenamiento
% El entrenamiento consiste en obtener los parámetros Gamma y xi utilizando
% la función <ParametrosMarkov.html ParametrosMarkov> para luego con estos obtener una media,
% varianza y matriz de transición nuevas. Este proceso se repite hasta que
% el log likelihood no varíe en mas de 10 unidades. Se irá mostrando en
% cada iteración los gráficos de las varianzas medias y puntos de cada
% clase.

TOLERANCIA = 1e-6;
likelihood = [];
continuar = true;
n = 1;
while continuar
    % OBTENGO GAMMA

    [alpha, beta, Gamma, xi] = ParametrosMarkov(means, vars, trans, x);
    Gamma = real(exp(Gamma))';
    
    % RECALCULO PARÁMETROS

    for k = 2:length(means)-1

        suma_gamma = sum(Gamma(:,k-1));

        % MEDIA
        means{k} = sum(Gamma(:,k-1).*train_set')'/suma_gamma;

        % VARIANZA
        numerador = 0;
        for i = 1:size(train_set,2)

            aux = (train_set(:,i) - means{k});
            aux = aux * aux';
            numerador = numerador + Gamma(i,k-1) * aux;

        end

         var_actual = numerador/suma_gamma;
         if rcond(var_actual) > TOLERANCIA
             vars{k} = var_actual;
         end
         
         
    end

    % MATRIZ DE TRANSICIÓN
    xi_normal = exp(xi);
    for j = 1:size(xi,1)
        for k = 1:size(xi,2)           
            numerador = sum(xi_normal(j,k,2:end));
            denominador = sum(sum(xi_normal(j,:,2:end)));
            trans(j+1,k+1) = numerador/denominador;            
        end
    end
    normalizador = sum(trans(end-1,:));
    trans(end-1,:) = trans(end-1,:) / normalizador;
    trans(end-1,end) = abs(1 - sum(trans(end-1,1:end-1)));
        
    figure
    hold on
    colores = 'rgb';
    
    for t = 1:size(x,1)
        aux = Gamma(t,:)*1000;
        aux = floor(aux)/1000;
        plot(x(t,1),x(t,2), '.', 'color', aux, 'markerSize',20)
    end
    
    
    for k = 2:length(means)-1
        elipse = obtener_elipse(means{k}, vars{k});
        plot(elipse(1,:),elipse(2,:), colores(k-1))
        plot(means{k}(1), means{k}(2), '+w', 'markerSize',10);
    end
    
    prob = logsum(alpha(:,10)+beta(:,10));
    likelihood = [likelihood prob];
    if length(likelihood) > 1 && prob-likelihood(end-1) < 10 && prob-likelihood(end-1) > 0
        continuar = false;
    end
    
    n = n + 1;
    if n > 50
        disp('Supero las 100 iteraciones, finaliza aca')
        continuar = false;
    end
    
end

%% Secuencia graficada con plotseq2
figure
plotseq2(x,stateSeq);


%% log Likelihood

figure
plot(likelihood, 'w')
ylabel('LogLikelihood')
xlabel('Número de iteración')

%% Comparación de las matrices de transición:

disp('Matriz de transición obtenida:')
disp(trans);

disp('Matriz de transición hmm4')
disp(hmm4.trans);

%% Definición de los parámetros para la generación de modelos hmm4 y hmm6
% Se define la matriz de transición para que genere modelos de markov hmm4
% y hmm6 indistintamente, con igual probabilidad de empezar en uno o en
% otro.

hmm_mixto.means = {[] hmm4.means{2:end-1} hmm6.means{2:end-1} []};
hmm_mixto.vars = {[] hmm4.vars{2:end-1} hmm6.vars{2:end-1} []};
hmm_mixto.trans = [...
         0  0.5    0    0     0.5    0    0    0      ;...
         0  0.9    0.1  0     0      0    0    0      ;...
         0  0      0.9  0.1   0      0    0    0       ;...
         0  0.1/3  0    0.9   0.1/3  0    0    0.1/3   ;...
         0  0      0    0     0.9    0.1  0    0      ;...
         0  0      0    0     0      0.9  0.1  0      ;...
         0  0.1/3  0    0     0.1/3  0    0.9  0.1/3  ;...
         0  0      0    0     0      0    0    1      ];
     

%% Secuencia obtenida con los parámetros definidos
     
[x,stateSeq] = genhmm(hmm_mixto);

%% Secuencia de estados más probable
% Determinación de la secuencia de estados más probable utilizando |logvit|
[stateSeq_vit,logProb_vit] = logvit(x,hmm_mixto);

diferencias = find(stateSeq-stateSeq_vit ~= 0);
if ~isempty(diferencias)
    disp(['Se detecto una diferencia en el subindice ' num2str(diferencias) ]);
else
    disp('No se detectaron diferencias entre la secuencia de estados mas probable y la secuencia de estados que realmente se generó');
end

disp('Secuencia generada:')
disp(stateSeq)

disp('Secuencia más probable:')
disp(stateSeq_vit)

%% Secuencia de modelos
% Obtengo la secuencia de modelos de la secuencia de estados más probable
secuencia = {};
hmm_iniciado = false;
for i = 2:length(stateSeq)-1
    if stateSeq_vit(i) == 2 && ~hmm_iniciado
        secuencia = [secuencia 'hmm4'];
        hmm_iniciado = true;
    elseif stateSeq_vit(i) == 5 && ~hmm_iniciado
        secuencia = [secuencia 'hmm6'];
        hmm_iniciado = true;
    elseif stateSeq_vit(i) ~= 2 && stateSeq_vit(i) ~= 5
        hmm_iniciado = false;
    end
end

disp('De la secuencia de estados más probable se obtiene la siguiente secuencia de modelos:')
disp(secuencia)

%% Comparación de las probabilidades
% Obtengo el logaritmo de la probabilidad de la secuencia generada para
% compararla con la calculada con viterbi.

logProb = logfwd(x,hmm_mixto);

disp('Logaritmo de la probabilidad de la secuencia generada:')
disp(logProb)
disp('Logaritmo de la probabilidad calculada con Viterbi:')
disp(logProb_vit)
