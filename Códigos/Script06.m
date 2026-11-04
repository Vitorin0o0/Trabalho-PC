clc;
clear;
close all;

%% Parametros da planta
Kp0 = 10.625;
tau = 90;
G = tf(Kp0, [tau 1]);

%% Controladores
% Controlador proporcional do Trabalho 2
K_P = 0.5;
C_P = K_P;

% Controlador PI projetado no Trabalho 3
K_p = 0.82071;
K_i = 0.010978;
C_PI = tf([K_p K_i], [1 0]);

%% Sistemas em malha fechada
T_P = feedback(C_P*G, 1);
T_PI = feedback(C_PI*G, 1);

%% Condicao equivalente de comparacao
% Deseja-se uma variacao de 1 ponto percentual na saida.
% Na malha aberta, o comando e calibrado para produzir essa variacao
% nominalmente: y_final = Kp0 * U_ab = 1.
referencia = 1;
U_ab = referencia/Kp0;

%% Respostas temporais
% O intervalo contempla a dinamica mais lenta (planta em malha aberta).
t = 0:0.1:500;

% Planta original em malha aberta
Y_ab = squeeze(step(G*U_ab, t));

% Sistema com controlador P
Y_P = squeeze(step(T_P, t));

% Sistema com controlador PI
Y_PI = squeeze(step(T_PI, t));

%% Sinais de controle
% Transferencias entre a referencia e o sinal de controle.
U_P_sys = feedback(C_P, G);
U_PI_sys = feedback(C_PI, G);

% Na malha aberta, o comando e constante apos a aplicacao do degrau.
u_ab = U_ab*ones(size(t));

% Nos sistemas realimentados, os sinais de controle sao respostas ao degrau
% unitario aplicado na referencia.
u_P = squeeze(step(U_P_sys, t));
u_PI = squeeze(step(U_PI_sys, t));

%% Grafico comparativo das saidas
figure('Name', 'Comparacao das respostas');
plot(t, Y_ab, 'LineWidth', 1.6);
hold on;
plot(t, Y_P, 'LineWidth', 1.6);
plot(t, Y_PI, 'LineWidth', 1.6);
plot([0 500], [referencia referencia], '--k', 'DisplayName', 'Referencia');
grid on;
xlim([0 500]);
xlabel('Tempo (s)');
ylabel('Variacao da umidade relativa (p.p.)');
title('Comparacao das respostas em malha aberta e malha fechada');
legend('Planta em malha aberta', 'Controlador P', 'Controlador PI', ...
       'Location', 'southeast');

%% Grafico comparativo dos sinais de controle
figure('Name', 'Comparacao dos sinais de controle');
plot(t, u_ab, 'LineWidth', 1.6);
hold on;
plot(t, u_P, 'LineWidth', 1.6);
plot(t, u_PI, 'LineWidth', 1.6);
grid on;
xlim([0 500]);
xlabel('Tempo (s)');
ylabel('Sinal de controle (V)');
title('Comparacao do esforco de controle');
legend('Malha aberta', 'Controlador P', 'Controlador PI', ...
       'Location', 'northeast');

%% Polos dos tres sistemas
polos_ab = pole(G);
polos_P = pole(T_P);
polos_PI = pole(T_PI);

fprintf('\n========== POLOS DOS SISTEMAS ==========' );
fprintf('\nPlanta em malha aberta:\n'); disp(polos_ab);
fprintf('Sistema com controlador P:\n'); disp(polos_P);
fprintf('Sistema com controlador PI:\n'); disp(polos_PI);

%% Indicadores das respostas
% stepinfo calcula os tempos em relacao ao valor final de cada resposta.
% A coluna ErroFinalRef mostra separadamente o erro em relacao a referencia
% comum de 1 p.p., permitindo identificar o erro estacionario.
info_ab = stepinfo(G*U_ab);
info_P = stepinfo(T_P);
info_PI = stepinfo(T_PI);

valor_final = [dcgain(G*U_ab); dcgain(T_P); dcgain(T_PI)];
erro_final = referencia - valor_final;
sobressinal = [info_ab.Overshoot; info_P.Overshoot; info_PI.Overshoot];
tempo_subida = [info_ab.RiseTime; info_P.RiseTime; info_PI.RiseTime];
tempo_acomodacao = [info_ab.SettlingTime; info_P.SettlingTime; info_PI.SettlingTime];

% Tempo para entrar e permanecer na banda de +/-2% da referencia comum.
% Se a resposta final nao alcanca essa banda, o resultado permanece NaN.
Y = [Y_ab(:), Y_P(:), Y_PI(:)];
tempo_acomodacao_ref = NaN(3,1);
banda_ref = 0.02*abs(referencia);
for k = 1:3
    fora_banda = find(abs(Y(:,k) - referencia) > banda_ref);
    if isempty(fora_banda)
        tempo_acomodacao_ref(k) = 0;
    elseif fora_banda(end) < length(t)
        tempo_acomodacao_ref(k) = t(fora_banda(end) + 1);
    end
end

indicadores = table(valor_final, erro_final, sobressinal, ...
                    tempo_subida, tempo_acomodacao, tempo_acomodacao_ref, ...
    'RowNames', {'Malha_aberta', 'Controlador_P', 'Controlador_PI'}, ...
    'VariableNames', {'ValorFinal_p_p', 'ErroFinalRef_p_p', ...
                      'Sobressinal_pct', 'TempoSubida_s', ...
                      'TempoAcomodacao_s', 'AcomodacaoRef_2pct_s'});

fprintf('\n========== INDICADORES DE DESEMPENHO ==========' );
disp(indicadores);

%% Esforco de controle
pico_u_ab = max(abs(u_ab));
pico_u_P = max(abs(u_P));
pico_u_PI = max(abs(u_PI));

fprintf('\n========== ESFORCO DE CONTROLE ==========' );
fprintf('\nComando constante em malha aberta: %.6f V\n', U_ab);
fprintf('Pico do sinal de controle com P: %.6f V\n', pico_u_P);
fprintf('Pico do sinal de controle com PI: %.6f V\n', pico_u_PI);
fprintf('Faixa de controle considerada: 0 a 3,3 V\n');

%% Verificacao da faixa de atuacao do PI
fprintf('Minimo do sinal de controle PI: %.6f V\n', min(u_PI));
fprintf('Maximo do sinal de controle PI: %.6f V\n', max(u_PI));
if min(u_PI) >= 0 && max(u_PI) <= 3.3
    fprintf('O sinal de controle PI permanece na faixa de 0 a 3,3 V.\n');
else
    fprintf('ATENCAO: o sinal de controle PI ultrapassa a faixa de 0 a 3,3 V.\n');
end
