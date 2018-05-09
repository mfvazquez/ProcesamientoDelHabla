function elipse = obtener_elipse(media, varianza)
    t = 0:0.01:2*pi;
    y =  [cos(t') sin(t')];
    elipse = abs(chol(varianza))*y';
    elipse = elipse + media;

end