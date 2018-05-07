function distorsion = calcular_distorsion(medias, clasificacion)
   
    distorsion = 0;
    for k = 1:length(clasificacion)
        distorsion = distorsion + calcular_distorsion_clase(clasificacion{k},medias(:,k));               
    end
    
end