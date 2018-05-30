close all
clear
clc

addpath('lib');
load(fullfile('data','data.mat'));

TOLERANCIA = 1e-6; % Tolerancia de error

%% EJERCICIO 1

% [x,stateSeq] = genhmm(hmm4.means,hmm4.vars,hmm4.trans);
% figure(1)
% plotseq(x,stateSeq)
% figure(2)
% plotseq2(x,stateSeq)


%% EJERCICIO 2

means = hmm4.means;
vars = hmm4.vars;
trans = hmm4.trans;
trans(trans<1e-100) = 1e-100;
logTrans = log(trans);


% logProb = logfwd(genhmm(hmm4.means,hmm4.vars,hmm4.trans),hmm4)
[x,stateSeq] = genhmm(means,vars,trans);
numStates = length(means);
nMinOne = numStates - 1;
[numPts,dim] = size(x);

%% CALCULO DE ALPHA

log2pi = log(2*pi);
for i=2:nMinOne
  invSig{i} = inv(vars{i});
  logDetVars2(i) = - 0.5 * log(det(vars{i})) - log2pi;
end

% Initialize the alpha vector for the emitting states
for i=2:nMinOne
  X = x(1,:)-means{i}';
  alpha(i) = logTrans(1,i) - 0.5 * (X * invSig{i}) * X' + logDetVars2(i);
end
alpha = alpha(:); %% alfa 1

alpha_uno = alpha;
% Do the forward recursion
for t = 2:numPts
  alphaBefore = alpha(:,t-1);
  for i = 2:nMinOne
    X = x(t,:)-means{i}';
    b = - 0.5 * (X * invSig{i}) * X' + logDetVars2(i);
    alpha(i,t) = logsum( alphaBefore(2:nMinOne) + logTrans(2:nMinOne,i) ) + b;
  end
end

alpha = alpha(2:end,:);

%% CALCULO DE BETA

beta(:,numPts) = logTrans(2:nMinOne,end);

for t = numPts-1:-1:1
  betaAfter = beta(:,t+1);
  for i = 2:nMinOne
    
    for z = 2:nMinOne
        X = x(t+1,:)-means{z}';
        b(z-1,1) = - 0.5 * (X * invSig{z}) * X' + logDetVars2(z);
    end
    
    beta(i-1,t) = logsum( betaAfter + logTrans(i,2:nMinOne)'  + b );
  end
end

% Verifico que sean todos iguales
for i = 1:size(alpha,2)
    resultado = logsum(alpha(:,i)+beta(:,i));
    if i > 2 && abs(resultado - anterior) > TOLERANCIA
        msgID = 'PROBABILIDAD:InconsistenciaValores';
        msg = ['logsum(alpha + beta) da distinto en el subindice ' num2str(i)];
        throw(MException(msgID,msg));
    end
    anterior = resultado;
end

%% CALCULO DE GAMMA

for i = 1:size(alpha,1)
    for t = 1:size(alpha,2)    
        divisor = logsum(alpha(:,i)+beta(:,i));
        gamma(i,t) = alpha(i,t) + beta(i,t) - divisor;    
    end
end

% Verifico que la suma de columnas de gamma den 1
gamma_exp = exp(gamma);
for i = 1:size(gamma_exp,2)
    instante = gamma_exp(:,i);
    sumatoria = sum(instante);
    if abs(sumatoria - 1) > TOLERANCIA
        msgID = 'GAMMA:InconsistenciaValores';
        msg = ['En el instante ' num2str(i) ' la sumatoria de los gammas no da 1'];
        throw(MException(msgID,msg));        
    end
end

%% Calculo xi

logTrans = logTrans(2:end-1,2:end-1);
for t = 2:size(alpha,2)
    divisor = logsum(alpha(:,t-1) + beta(:,t-1));
    for k = 1:size(alpha,1)
        X = x(t,:)-means{k+1}';
        b = - 0.5 * (X * invSig{k+1}) * X' + logDetVars2(k+1);        
        for j = 1:size(alpha,1)
            xi(j,k,t-1) = alpha(j,t-1) + beta(k,t) + logTrans(j,k) + b - divisor;
        end
    end
end

% Verifico valores de xi
for t = 1:size(xi,3)
    for k = 1:size(gamma,1)
        resultado = logsum(xi(:,k,t))
        gamma(k,t)
        if abs(resultado - gamma(k,t)) > TOLERANCIA
            disp('ALTO ERROR WACHO')
        end
    end
end




