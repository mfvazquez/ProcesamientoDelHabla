function distorsion = calcular_distorsion(medias, clasificacion)
   
    distorsion = 0;
    for k = length(clasificacion)
        for i = 1:size(clasificacion{k},2)
            distorsion = distorsion + (norm(clasificacion{k}(:,i)-medias(:,k)))^2;
        end
    end
    
end