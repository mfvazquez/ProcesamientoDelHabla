%% Sintetizar
% Funcion que sintetiza una señal mediante el error y los coeficientes LPC.
% ancho es el ancho de la ventana utilizada, y zf las condiciones
% iniciales.
function salida = sintetizar(error, coeficientes, ancho, zf)
    
    inicios = 1:ancho:length(error)-ancho;
    salida = [];
    for x = 1:length(inicios)
        error_actual = error(inicios(x):inicios(x)+ancho-1);
        [S_actual, zf] = filter(1, [-1;coeficientes(:,x)], error_actual, zf);
        salida = [salida S_actual(1:ancho)];
    end
end