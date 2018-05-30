close all
clear
clc

addpath('lib');
load(fullfile('data','data.mat'));

%% EJERCICIO 1

% [x,stateSeq] = genhmm(hmm4.means,hmm4.vars,hmm4.trans);
% figure(1)
% plotseq(x,stateSeq)
% figure(2)
% plotseq2(x,stateSeq)


%% EJERCICIO 2

means = hmm4.means;
vars = hmm4.vars;
trans = [0   1   0   0   0  ;...
         0   0.5 0.5 0   0  ;...
         0   0   0.5 0.5 0  ;...
         0   0   0   0.5 0.5;...
         0   0   0   0   1  ];
trans(trans<1e-100) = 1e-100;

x = [];
while length(x) < 5
    [x,stateSeq] = genhmm(means,vars,trans);
end
train_set = x';

media_inicial = calcular_media(x');
means(2:end-1) = {media_inicial};

varianza_inicial = calcular_varianza(x',media_inicial);
vars(2:end-1) = {varianza_inicial};



TOLERANCIA = 1e-6;
likelihood = [];
for M = 1:20

    %% OBTENGO GAMMA

    [alpha, beta, Gamma, xi] = ParametrosMarkov(means, vars, trans, x);
    Gamma = exp(Gamma)';
    
    %% RECALCULO PARAMETROS

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
         if rcond(var_actual) < TOLERANCIA
             break
         end
         
    end

    %% MATRIZ DE TRANSICION

    
    %% DIBUJAR COMO VA CATEGORIZANDO EN CADA ITERACION
   
end % ESTO DEBERIA TERMINAR CUANDO P(X) ya no cambia, que seria el likelihood

