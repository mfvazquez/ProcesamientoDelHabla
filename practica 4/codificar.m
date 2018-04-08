function salida = codificar(error, coeficientes, ancho, zf)
    % ZF son las condiciones iniciales

    inicios = 1:ancho:length(error)-ancho;
    salida = [];
    for x = 1:length(inicios)
        error_actual = error(inicios(x):inicios(x)+ancho-1);
        [S_actual, zf] = filter(1, [-1;coeficientes(:,x)], error_actual, zf);
        salida = [salida S_actual(1:ancho)];
    end
end