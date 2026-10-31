% Código - Efeito do ganho proporcional
clear;
clc;
close all;

% Planta: umidificador + camara
k = 42.5;
Kh = 0.25;
tau = 90;

G = tf(k * Kh, [tau 1]);

% Ganhos analisados
ganhos = [0.1; 0.5; 1.0];

% Referencia: degrau de 1 ponto percentual
t = (0:0.05:400)';
r = ones(size(t));

% Colunas:
% K, polo, erro, subida, acomodacao, pico, sobressinal, valor final
dados = zeros(length(ganhos), 8);

figure;
hold on;

for i = 1:length(ganhos)
    K = ganhos(i);

    % Malha fechada com realimentacao negativa unitaria
    T = feedback(K * G, 1);

    % Resposta temporal
    y = lsim(T, r, t);

    % Valor final e erro estacionario
    valorFinal = dcgain(T);
    erro = 1 - valorFinal;

    % Indicadores em relacao ao valor final de cada resposta
    info = stepinfo(y, t, valorFinal, ...
        'RiseTimeLimits', [0.1 0.9], ...
        'SettlingTimeThreshold', 0.02);

    % Nao existe pico transitorio na resposta monotona
    tempoPico = NaN;

    dados(i, :) = [K, pole(T), erro, ...
        info.RiseTime, info.SettlingTime, ...
        tempoPico, info.Overshoot, valorFinal];

    plot(t, y, 'LineWidth', 2, ...
        'DisplayName', sprintf('K = %.1f', K));
end

% Referencia no mesmo grafico
plot(t, r, '--k', 'LineWidth', 1.5, ...
    'DisplayName', 'Referencia: 1 ponto percentual');

grid on;
xlabel('Tempo (s)');
ylabel('Variacao de umidade (pontos percentuais)');
title('Efeito do ganho proporcional em malha fechada');
legend('show', 'Location', 'southeast');
xlim([0 400]);
ylim([0 1.1]);
hold off;

% Tabela comparativa
resultados = array2table(dados, ...
    'VariableNames', {'K', 'Polo', 'Erro_pp', ...
    'TempoSubida_s', 'TempoAcomodacao_s', ...
    'TempoPico_s', 'Sobressinal_pct', 'ValorFinal_pp'});

disp(resultados);
disp('NaN no tempo de pico significa: nao se aplica.');

% Salvar grafico e tabela na pasta atual
exportgraphics(gcf, 'Etapa5_Grafico.png', 'Resolution', 300);
writetable(resultados, 'Etapa5_Resultados.csv');