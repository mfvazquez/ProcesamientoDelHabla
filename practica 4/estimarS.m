function [S_estimado, rho, B] = estimarS(S,ancho,M)

    autocorrelacion = xcorr(S);
    rho = autocorrelacion(ancho:ancho+M-1);   % rho = [rho(0) rho(1) ... rho(M)]

    subindices = toeplitz(1:M-1);
    R = rho(subindices);

    B= R\rho(2:M);  % inv(R) * rho(2:M)

    S_estimado = filter([0; B],1 ,S);

end