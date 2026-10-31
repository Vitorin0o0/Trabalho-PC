
clear; clc; close all;

%% Parametros do sistema

k = 42.5;
tau = 90;
Kh = 0.25;

Kp0 = Kh*k;

%% Funcao de transferencia em malha aberta

G_LGR = tf(Kp0, [tau 1]);

disp('Funcao de transferencia em malha aberta:');
G_LGR

%% Identificacao de polos e zeros

disp('Polos de malha aberta:');
disp(pole(G_LGR));

disp('Zeros de malha aberta:');
disp(zero(G_LGR));

%% Construcao do Lugar Geometrico das Raizes

figure('Color','w');

rlocus(G_LGR);
grid on;
hold on;

title('Lugar Geometrico das Raizes - Controlador Proporcional');
xlabel('Eixo Real');
ylabel('Eixo Imaginario');

%% Informacoes dos polos de malha fechada

Ks = [0 0.1 0.5 1.0 2.0 4.0];

disp('Polos de malha fechada para diferentes ganhos:');

for K = Ks

    p = pole(feedback(K*G_LGR, 1));

    fprintf('K = %.2f -> Polo = %.5f\n', K, p);

end

%% Caracteristicas do LGR

p = pole(G_LGR);
z = zero(G_LGR);

n = length(p);
m = length(z);

fprintf('\nNumero de ramos: %d\n', n);

if n > m

    centroide = (sum(p)-sum(z))/(n-m);

    fprintf('Centroide das assintotas: %.5f\n', centroide);

    for q = 0:(n-m-1)

        angulo = (2*q+1)*180/(n-m);

        fprintf('Assintota %d: %.1f graus\n', q+1, angulo);

    end

end
