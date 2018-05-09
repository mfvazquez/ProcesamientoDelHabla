function graficar_clasificacion(colores, clasificacion, medias)
    
    for x = 1:length(clasificacion)
        plot(clasificacion{x}(1,:),clasificacion{x}(2,:), [colores(x) 'o'])
        hold on;
            
        if nargin == 3
            plot(medias(1,x), medias(2,x), [colores(x) '+'],'linewidth',3);
        end
    end

end