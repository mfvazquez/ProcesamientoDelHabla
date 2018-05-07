function clasificacion = clasificar_lineal(formantes_limites, formantes, subindice)
  
    for x = 1:length(formantes_limites)+1
        clasificacion{x} = [];
    end
    
    for x = 1:size(formantes,2)
        actual = formantes(subindice,x);        
        
        resultado = actual > formantes_limites;
        clase = find(resultado,1,'last');
        if isempty(clase) % ES MENOR AL ANGULO MAS CHICO
            clase = 1;
        else
            clase = clase + 1;
        end
        
        clasificacion{clase}(:,end+1) = formantes(:,x);

    end
    
end


