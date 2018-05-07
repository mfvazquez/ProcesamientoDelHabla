function distorsion = calcular_distorsion_clase(formantes, media)
    distorsion = 0;
    for i = 1:size(formantes,2)
        distorsion = distorsion + norm(formantes(:,i)-media);
    end

end