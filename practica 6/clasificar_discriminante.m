function clasificacion = clasificar_discriminante(g, formantes)

    for x = 1:length(g)
        clasificacion{x} = [];
    end

    for n = 1:size(formantes,2)
        actual = formantes(:,n);
        
        for k = 1:length(g)
            resultados(k) = g{k}(actual);
        end
        
        clase = find(max(resultados) == resultados);
        clasificacion{clase}(:,end+1) = actual;
        
    end
    
end