function clasificacion = clasificacion_euclidea(medias, formantes)

    for x = 1:size(medias,2)
        clasificacion{x} = [];
    end

    
    for x = 1:size(formantes,2)        
        actual = formantes(:,x);
        
        for y = 1:size(medias,2)        
            distancias(y) = norm(medias(:,y) - actual);
        end
        
        clase = find(min(distancias) == distancias);
        clasificacion{clase}(:,end+1) = actual;
        
    end
    
end