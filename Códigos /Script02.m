% Analise de estabilidade
clear;
clc;
close all;

% Planta validada
k = 42.5;
Kh = 0.25;
tau = 90;
G = tf(k * Kh, [tau 1]);

% Ganhos selecionados
Kcritico = -1 / (k * Kh);
ganhos = [0.5, Kcritico, -0.2];
casos = {'Estavel', 'Critico', 'Instavel'};

% Degrau de referencia de 1 ponto percentual
t = (0:0.1:400)';
r = ones(size(t));

figure;

for i = 1:numel(ganhos)
    K = ganhos(i);

    % Expressao analitica da malha fechada
    termoConstante = 1 + k * Kh * K;

    % Representa exatamente o polo na origem no caso critico
    if i == 2
        termoConstante = 0;
    end

    T = tf(k * Kh * K, [tau termoConstante]);

    fprintf('\nCaso %s: K = %.8f\n', casos{i}, K);
    disp('Polos de malha fechada:');
    disp(pole(T));

    y = lsim(T, r, t);

    subplot(3, 1, i);
    plot(t, y, 'b', 'LineWidth', 1.8);
    hold on;
    plot(t, r, '--k', 'LineWidth', 1);
    grid on;

    title(sprintf('%s: K = %.6f', casos{i}, K));
    xlabel('Tempo (s)');
    ylabel('Variacao de UR (p.p.)');
    legend('Saida', 'Referencia', 'Location', 'best');
end
