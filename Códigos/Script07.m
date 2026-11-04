
clc;
clear;
close all;

%% Parametros nominais da planta
Kh = 0.25;
tau = 90;

% Ganhos fixos do controlador PI
K_p = 0.82071;
K_i = 0.010978;

C_PI = tf([K_p K_i], [1 0]);

%% Variacao do ganho estatico da camara
% Valores: -20%, nominal e +20%
k_vec = [34 42.5 51];

nomes = {'Abaixo do nominal', ...
         'Valor nominal', ...
         'Acima do nominal'};

%% Tempo de simulacao e referencia
t = 0:0.1:500;
referencia = 1;

% Armazenamento dos resultados
Y = zeros(length(t), length(k_vec));
U = zeros(length(t), length(k_vec));

polos = cell(1, length(k_vec));

valor_final = zeros(3,1);
erro_final = zeros(3,1);
sobressinal = zeros(3,1);
tempo_subida = zeros(3,1);
tempo_acomodacao = zeros(3,1);
estabilidade = cell(3,1);
controle_min = zeros(3,1);
controle_max = zeros(3,1);

%% Simulacoes
for i = 1:length(k_vec)

    % Planta com o ganho estatico alterado
    k = k_vec(i);
    Kp0 = Kh*k;

    G = tf(Kp0, [tau 1]);

    % Sistema em malha fechada com PI fixo
    T_PI = feedback(C_PI*G, 1);

    % Funcao de transferencia entre referencia e controle
    U_PI_sys = feedback(C_PI, G);

    % Resposta da saida
    Y(:,i) = squeeze(step(T_PI, t));

    % Resposta do sinal de controle
    U(:,i) = squeeze(step(U_PI_sys, t));

    % Polos e estabilidade
    polos{i} = pole(T_PI);

    if all(real(polos{i}) < 0)
        estabilidade{i} = 'Estavel';
    else
        estabilidade{i} = 'Instavel';
    end

    % Indicadores de desempenho
    info = stepinfo(T_PI, ...
        'RiseTimeLimits', [0.1 0.9], ...
        'SettlingTimeThreshold', 0.02);

    valor_final(i) = dcgain(T_PI);
    erro_final(i) = referencia - valor_final(i);
    sobressinal(i) = info.Overshoot;
    tempo_subida(i) = info.RiseTime;
    tempo_acomodacao(i) = info.SettlingTime;

    % Limites do sinal de controle
    controle_min(i) = min(U(:,i));
    controle_max(i) = max(U(:,i));

end

%% Grafico comparativo das respostas
figure('Name', 'Robustez - Respostas');

plot(t, Y(:,1), 'LineWidth', 1.6);
hold on;
plot(t, Y(:,2), 'LineWidth', 1.6);
plot(t, Y(:,3), 'LineWidth', 1.6);
yline(referencia, '--k', 'Referencia');

grid on;
xlim([0 500]);
xlabel('Tempo (s)');
ylabel('Variacao da umidade relativa (p.p.)');
title('Robustez do controlador PI - Respostas');
legend(nomes, 'Location', 'southeast');

%% Grafico comparativo dos sinais de controle
figure('Name', 'Robustez - Esforco de controle');

plot(t, U(:,1), 'LineWidth', 1.6);
hold on;
plot(t, U(:,2), 'LineWidth', 1.6);
plot(t, U(:,3), 'LineWidth', 1.6);

grid on;
xlim([0 500]);
xlabel('Tempo (s)');
ylabel('Sinal de controle (V)');
title('Robustez do controlador PI - Esforco de controle');
legend(nomes, 'Location', 'northeast');

%% Tabela de indicadores
indicadores = table(k_vec', valor_final, erro_final, ...
    sobressinal, tempo_subida, tempo_acomodacao, estabilidade, ...
    'VariableNames', {'Ganho_k', 'ValorFinal', 'ErroFinal', ...
    'Sobressinal_pct', 'TempoSubida_s', ...
    'TempoAcomodacao_s', 'Estabilidade'}, ...
    'RowNames', {'Abaixo', 'Nominal', 'Acima'});

fprintf('\n========== INDICADORES DE DESEMPENHO ==========\n');
disp(indicadores);

%% Polos dos sistemas
fprintf('\n========== POLOS DE MALHA FECHADA ==========\n');

for i = 1:length(k_vec)
    fprintf('\n%s (k = %.2f):\n', nomes{i}, k_vec(i));
    disp(polos{i});
end

%% Analise do sinal de controle
fprintf('\n========== LIMITES DO SINAL DE CONTROLE ==========\n');

for i = 1:length(k_vec)

    fprintf('\n%s:\n', nomes{i});
    fprintf('Minimo: %.6f V\n', controle_min(i));
    fprintf('Maximo: %.6f V\n', controle_max(i));

    if controle_min(i) >= 0 && controle_max(i) <= 3.3
        fprintf('Sinal dentro da faixa de 0 a 3,3 V.\n');
    else
        fprintf('ATENCAO: sinal fora da faixa de 0 a 3,3 V.\n');
    end

end
