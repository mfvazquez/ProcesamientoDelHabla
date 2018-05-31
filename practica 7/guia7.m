close all
clear
clc

addpath('lib');
load(fullfile('data','data.mat'));

%% EJERCICIO 1
% 
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

while true
    [x,stateSeq] = genhmm(hmm4);
    
    if length(x) < 100
        continue
    end

    for z = 2:length(hmm2.means)-1
        if sum(stateSeq == z) < 15
            continue
        end
    end
    
    break
    
end
train_set = x';

media_inicial = calcular_media(x');
means(2:end-1) = {media_inicial};

varianza_inicial = calcular_varianza(x',media_inicial);
vars(2:end-1) = {varianza_inicial};



TOLERANCIA = 1e-16;
likelihood = [];
for M = 1:20

    %% OBTENGO GAMMA

    [alpha, beta, Gamma, xi] = ParametrosMarkov(means, vars, trans, x);
    Gamma = real(exp(Gamma))';
    parametros_actuales.alpha = alpha;
    parametros_actuales.beta = beta;
    parametros_actuales.Gamma = Gamma;
    parametros_actuales.xi = xi;
    
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
%          if rcond(var_actual) < TOLERANCIA
%              break
%          end
         vars{k} = var_actual;
         
    end

    %% MATRIZ DE TRANSICION
    xi_normal = exp(xi);
    for j = 1:size(xi,1)
        for k = 1:size(xi,2)           
            numerador = sum(xi_normal(j,k,2:end));
            denominador = sum(sum(xi_normal(j,:,2:end)));
            trans(j+1,k+1) = numerador/denominador;            
        end
    end
    trans(end-1,end) = abs(1 - sum(trans(end-1,1:end-1)));
    
    parametros_actuales.trans = trans;
    
    viejos(M) = parametros_actuales;

    
    %% DIBUJAR COMO VA CATEGORIZANDO EN CADA ITERACION

    figure
    hold on
%     plotseq2(x,stateSeq)
    colores = 'rgb';
    
    for t = 1:size(x,1)
%         clase = find(Gamma(t,:) == max(Gamma(t,:)));
%         plot(x(t,1),x(t,2),'o','color',colores(clase(1)));
        aux = Gamma(t,:)*1000;
        aux = floor(aux)/1000;
        plot(x(t,1),x(t,2), 'o', 'color', aux)
    end
    
    
    for k = 2:length(means)-1
        elipse = obtener_elipse(means{k}, vars{k});
        plot(elipse(1,:),elipse(2,:), colores(k-1))
        plot(means{k}(1), means{k}(2), ['+' colores(k-1)]);
    end
    
    
end % ESTO DEBERIA TERMINAR CUANDO P(X) ya no cambia, que seria el likelihood

