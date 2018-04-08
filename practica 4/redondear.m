%% Redondear
% Funcion redondea a punto fijo a una precisión dada por el numero de bits
% ingresados.

function vector_redondeado = redondear(vector, numero_de_bits)

    precision = 2^numero_de_bits-1;

    offset = min(vector);    
    vector_redondeado = vector - offset; % le agrego offset para que sea positivo
    
    maximo = max(vector_redondeado);
    
    vector_redondeado = (vector_redondeado)*precision/maximo;
    vector_redondeado = round(vector_redondeado);
    
    vector_redondeado = vector_redondeado*maximo/precision;
    vector_redondeado = vector_redondeado+offset;
    
end