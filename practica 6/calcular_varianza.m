function varianza = calcular_varianza(vector, media)

    varianza = 0;
    for y = 1:size(vector,2)
        X = vector(:,y);
        varianza = varianza + (X-media)*(X-media)';
    end
    varianza = varianza/size(vector,2);

end

