function Gamma = calcular_gamma(parametros, formantes)

    for k = 1:length(parametros)    
        Gamma(k) = mvnpdf(formantes,parametros(k).media,parametros(k).varianza) * parametros(k).pi;
    end        
    Gamma = Gamma./sum(Gamma);

end