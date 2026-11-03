
clc;
clear;
close all;

% Parametros da planta
Kp0 = 10.625;
tau = 90;

% Especificacoes do projeto
Mp_max = 2;
tr_max = 35;
ts_max = 60;

% Intervalos de busca
zeta_vec = 0.78:0.02:2.00;
wn_vec = 0.005:0.001:0.12;

% Armazenamento dos resultados
resultados = [];

for zeta = zeta_vec
    for wn = wn_vec

        % Calculo dos ganhos
        Kp = (180*zeta*wn - 1)/Kp0;
        Ki = (tau*wn^2)/Kp0;

        % Evita ganho proporcional negativo
        if Kp <= 0
            continue;
        end

        % Controlador PI
        C = tf([Kp Ki], [1 0]);

        % Planta
        G = tf(Kp0, [tau 1]);

        % Funcao de transferencia em malha fechada
        T = feedback(C*G, 1);

        % Analise da resposta ao degrau
        info = stepinfo(T, ...
            'RiseTimeLimits', [0.1 0.9], ...
            'SettlingTimeThreshold', 0.02);

        % Verificacao dos requisitos
        if info.Overshoot <= Mp_max && ...
           info.RiseTime <= tr_max && ...
           info.SettlingTime <= ts_max

            resultados = [resultados;
                zeta, wn, Kp, Ki, ...
                info.Overshoot, ...
                info.RiseTime, ...
                info.SettlingTime];
        end

    end
end

% Exibe os resultados encontrados
if isempty(resultados)
    disp('Nenhuma combinacao atende aos requisitos.');
else
    tabela = array2table(resultados, ...
        'VariableNames', ...
        {'Zeta','Wn','Kp','Ki', ...
         'Sobressinal','TempoSubida','TempoAcomodacao'});

    % Ordena pelo menor tempo de acomodacao
    tabela = sortrows(tabela, 'TempoAcomodacao');

    disp(tabela);
end
