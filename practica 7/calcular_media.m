function media = calcular_media(vector)
    media = 0;
    for x = 1:size(vector,2)
        media = media + vector(:,x);
    end
    media = media./size(vector,2);
end