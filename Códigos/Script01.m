% Parâmetros do sistema
k = 42.5;
tau = 90;
Kh = 0.25;

% Função de Transferência da Planta (Malha Aberta)
num = [Kh * k];
den = [tau 1];
Gp = tf(num, den);

% Exibe Polos e Zeros no terminal
disp('Polos do sistema:');
pole(Gp)
disp('Zeros do sistema:');
zero(Gp)

% Configuração da entrada degrau (3.3V simulando o ESP32)
amplitude = 3.3;
t = 0:0.1:400; % Vetor de tempo de 0 a 400 segundos
u = amplitude * ones(size(t)); % Sinal degrau

% Simulação da resposta temporal
[y, t] = lsim(Gp, u, t);

% Geração do Gráfico
figure;
plot(t, y, 'LineWidth', 2);
title('Resposta Temporal da Planta (Malha Aberta)');
xlabel('Tempo (s)');
ylabel('Umidade Relativa (%)');
grid on;
