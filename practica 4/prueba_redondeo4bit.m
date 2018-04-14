S = 0:1000;



vector_redondeado = redondear(S, 4);

figure
plot(S)
hold on
plot(vector_redondeado)
legend('S','S redondeado')


f = 0:0.0001:2*pi;
S = sin(f);

S_redondeado = redondear(S,4);

figure
plot(S)
hold on
plot(S_redondeado)
legend('S','S redondeado')
