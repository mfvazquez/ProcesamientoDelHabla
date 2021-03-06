%% ParametrosMarkov
% Función que obtiene los parámetros alpha, beta gamma y xi a partir de la
% media, varianza, matriz de transición y la secuencia recibida.
function [alpha, beta, gamma, xi] = ParametrosMarkov(means, vars, trans, x)

TOLERANCIA = 1e-6; % Tolerancia de error

logTrans = log(trans);

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
        msgID = 'ALPHA_BETA:InconsistenciaValores';
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
    divisor = logsum(alpha(:,t) + beta(:,t));
%     divisor = logsum(gamma(:,t));
    for k = 1:size(alpha,1)
        X = x(t,:)-means{k+1}';
        b = - 0.5 * (X * invSig{k+1}) * X' + logDetVars2(k+1);        
        for j = 1:size(alpha,1)
            xi(j,k,t) = alpha(j,t-1) + beta(k,t) + logTrans(j,k) + b - divisor;
        end
    end
end

% Verifico valores de xi
for t = 2:size(xi,3)
    for j = 1:size(gamma,1)
        resultado = logsum(xi(j,:,t));
        if abs(resultado - gamma(j,t-1)) > TOLERANCIA
            msgID = 'XI:InconsistenciaValoresFILAS';
            msg = ['En el instante ' num2str(t) ' de la clase ' num2str(j) ' Xi no coincide con Gamma'];
            throw(MException(msgID,msg));            
        end
    end
end

% Verifico valores de xi
for t = 2:size(xi,3)
    for k = 1:size(gamma,1)
        resultado = logsum(xi(:,k,t));
        if abs(resultado - gamma(k,t)) > TOLERANCIA
            msgID = 'XI:InconsistenciaValoresCOLUMNAS';
            msg = ['En el instante ' num2str(t) ' de la clase ' num2str(k) ' Xi no coincide con Gamma'];
            throw(MException(msgID,msg));            
        end
    end
end

end