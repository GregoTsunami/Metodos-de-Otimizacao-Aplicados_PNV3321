function [d_max, x_traj, y_traj] = foguete_dist_max(m_agua, theta)
    % Parâmetros
    mg = 0.1; % MassaFoguete (kg)
    Vg = 0.003; % VolumeGarrafa (m^3)
    Ab = 7.85398e-5; % AreaBocal (m^2)
    Af = 7.853982e-3; % AreaFrontal (m^2)
    
    P = 300000; % PressaoLançamento (Pa)
    
    hr = 1; % AlturaRampa (m)
    rho_agua = 1000; % DensidadeAgua (kg/m^3)
    rho_ar = 1.4; % DensidadeAr (kg/m^3)
    Patm = 101325; % PressaoAtmosferica (Pa)
    Ca = 0.5; % CoefArrasto
    g = 9.8; % Gravidade (m/s^2)
    dt = 0.005; % PassoTempo (s)
    
    % Condições iniciais
    t_k = 0; % TempoInicial (s)
    d_k = 0.0; % DistXInicial (m)
    h_k = 0.0; % AlturaInicial (m)
    Ux_k = 0.01; % VelocidadeXInicial (m/s)
    Uy_k = 0.01; % VelocidadeYInicial (m/s)
    ax_k = 0.0; % AceleracaoXInicial (m/s^2)
    ay_k = 0.0; % AceleracaoYInicial (m/s^2)
    P_k = P; % PressaoInternaInicial (Pa)
    m_agua_k = m_agua; % MassaAguaInicial (kg)
    theta_k = theta; %AnguloFoguete (°)
    %U_agua_k = 0; %VelocidadeAguaInicial (m/s)

    % Plot do gráfico
    x_traj = []; % Trajetória em X
    y_traj = []; % Trajetória em Y
    
    % Simulação
    while h_k >= 0

        % Velocidade água
        if P_k - Patm > 0
            U_agua_k = sqrt(2 * (P_k - Patm) / rho_agua);
        else
            U_agua_k = 0;
        end

        % Massa água
        m_agua_anterior = m_agua_k; % m_agua^(k-1)
        m_agua_k = max(m_agua_k - U_agua_k * Ab * rho_agua * dt, 0); % m_agua^(k)

        % Pressão
        if m_agua_k > 0
            P_k = P_k * (Vg - m_agua_anterior / rho_agua) / (Vg - m_agua_k / rho_agua);
        else
            P_k = 0; % Após ejeção total da água, pressão igual à zero
        end

        % Empuxo
        E_k = max((P_k - Patm) * Ab, 0);
        
        % Arrasto
        Fa_k = 0.5 * Ca * rho_ar * ((Ux_k)^2 + (Uy_k)^2) * Af;
        
        % Normal, Acelerações e Ângulo Foguete
        if (h_k < hr) && (d_k < hr / tan(theta_k)) && (Uy_k > 0)
            N_k = g * (mg + m_agua_k) * cos(theta_k);
            ax_k = ((E_k - Fa_k) * cos(theta_k) - N_k * sin(theta_k)) / (m_agua_k + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_k) + N_k * cos(theta_k)) / (m_agua_k + mg) - g;
        else
            %N_k = 0;
            theta_ka = atan(Uy_k/Ux_k);
            ax_k = ((E_k - Fa_k) * cos(theta_ka)) / (m_agua_k + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_ka)) / (m_agua_k + mg) - g;
        end
        
        % Velocidades
        if h_k >= 0
            Ux_k = Ux_k + ax_k*dt;
            Uy_k = Uy_k + ay_k*dt;
        else
            Ux_k = 0;
            Uy_k = 0;
        end

        % Posições
        d_k = d_k + Ux_k * dt + 0.5 * ax_k * dt^2;
        h_k = h_k + Uy_k * dt + 0.5 * ay_k * dt^2;

        % Trajetórias por loop
        x_traj = [x_traj, d_k];
        y_traj = [y_traj, h_k];

        % Tempo
        t_k = t_k + dt;
        
        % % Prints para Verificação
        % fprintf(['d_k = %.5f\n' ...
        %  'h_k = %.5f\n' ...
        %  'Ux_k = %.5f\n' ...
        %  'Uy_k = %.5f\n' ...
        %  'ax_k = %.5f\n' ...
        %  'ay_k = %.5f\n' ...
        %  'Fa_k = %.5f\n' ...
        %  'E_k = %.5f\n' ...
        %  'P_k = %.5f\n' ...
        %  'm_agua_k = %.5f\n' ...
        %  'U_agua_k = %.5f\n'], ...
        %  d_k, h_k, Ux_k, Uy_k, ax_k, ay_k, Fa_k, E_k, P_k, m_agua_k, U_agua_k);

        % fprintf('\n');

    end

    % Distância Máxima Horizontal
    d_max = max(x_traj);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A)

% Chutes Iniciais
m_agua = 0.5; % Massa inicial de água (kg) 
theta = deg2rad(45); % Ângulo da rampa (graus)

% Função e Resultado
[d_max, x_traj, y_traj] = foguete_dist_max(m_agua, theta);
fprintf('A distância máxima horizontal é %.5f metros.\n', d_max);

% Plotar a trajetória
figure;
plot(x_traj, y_traj, 'b-', 'LineWidth', 1.5);
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Trajetória do Foguete');
grid on;

text(0.02*max(x_traj), 0.95*max(y_traj), ...
    sprintf('Massa água = %.3f kg\nÂngulo = %.2f°\nDistância = %.2f m', ...
    m_agua, theta, d_max), ...
    'FontSize', 10, 'BackgroundColor', 'white');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B)

% Função Objetivo:
% Maximizar d_max(m_agua, theta)
% Minimizar -d_max(m_agua, theta)


% Variávveis e Restrições:
% m_agua: [0.1, 3.0] kg (0 < m_agua < rho_agua*Vg)
% theta: [0, 90] ° (0 < theta < 90°)
% P_k - Patm > 0 para ejetar


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C)

% Intervalo para Variáveis
m_agua_min = 0.1; % (kg)
m_agua_max = 2.9; % (kg)

theta_min = 10.1; % (°)
theta_max = 89.9; % (°)

m_agua_values = linspace(m_agua_min, m_agua_max, 100);
theta_values = deg2rad(linspace(theta_min, theta_max, 100));

% Função Objetivo
[M_agua, Theta] = meshgrid(m_agua_values, theta_values);
fobj_values = arrayfun(@(m, theta) foguete_dist_max(m, theta), M_agua, Theta);

% Verificação do máximo global
[max_dist, max_idx] = max(fobj_values(:));
[max_row, max_col] = ind2sub(size(fobj_values), max_idx);
fprintf('Máxima distância: %.2f m, com θ = %.2f° e massa = %.2f kg\n', ...
    max_dist, theta_values(max_col), m_agua_values(max_row));

% Plotando o gráfico 3D
figure;
surf(M_agua, rad2deg(Theta), fobj_values, 'EdgeColor', 'none');
colormap('jet');
xlabel('Massa de Água (kg)');
ylabel('Ângulo de Inclinação (°)');
zlabel('Distância Máxima (m)');
title('M_agua x Theta x fobj');
colorbar;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D)

% Função Objetivo: min -d_max
function neg_d_max = obj_foguete(params)
    m_agua = params(1);
    theta = params(2);
    [d_max, ~, ~] = foguete_dist_max(m_agua, theta);
    neg_d_max = -d_max; 
end

% Limites
lb = [m_agua_min, deg2rad(theta_min)]; % Limite inferior
ub = [m_agua_max, deg2rad(theta_max)]; % Limite superior

% Chute Inicial
x0 = [0.5, deg2rad(45)];

% Fmincon
options = optimoptions('fmincon', 'Display', 'iter', 'Algorithm', 'sqp');
[x_opt, fval] = fmincon(@obj_foguete, x0, [], [], [], [], lb, ub, [], options);

% Resultados
m_agua_opt = x_opt(1);
theta_opt = rad2deg(x_opt(2));
d_max_opt = -fval; % Volta o valor positivo da distância
fprintf('Solução Ótima da FMINCON:\nMassa Água: %.3f kg\nÂngulo: %.2f°\nDistância Máxima: %.2f m\n', ...
    m_agua_opt, theta_opt, d_max_opt);

% Função com os valores ótimos
[d_max_opt, x_traj_opt, y_traj_opt] = foguete_dist_max(m_agua_opt, deg2rad(theta_opt));

% Gráfico da trajetória otimizada
figure;
plot(x_traj_opt, y_traj_opt, 'r-', 'LineWidth', 2);
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Trajetória do Foguete (Otimizada)');
grid on;

text(0.02*max(x_traj_opt), 0.95*max(y_traj_opt), ...
    sprintf('Massa água = %.3f kg\nÂngulo = %.2f°\nDistância = %.2f m', ...
    m_agua_opt, theta_opt, d_max_opt), ...
    'FontSize', 10, 'BackgroundColor', 'white');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E)

% Trajetórias
[d_max_1, x_traj_1, y_traj_1] = foguete_dist_max(m_agua, theta);
[d_max_2, x_traj_2, y_traj_2] = foguete_dist_max(m_agua_opt, deg2rad(theta_opt));

% Gráfico comparativo
figure;
hold on;
plot(x_traj_1, y_traj_1, 'b-', 'LineWidth', 1.5); % Trajetória 1 em azul
plot(x_traj_2, y_traj_2, 'r-', 'LineWidth', 1.5); % Trajetória 2 em vermelho
hold off;

% Configurações do gráfico
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Comparação de Trajetórias do Foguete');
grid on;

% Legenda
legend({sprintf('Trajetória 1: Distância = %.2f m', d_max_1), ...
        sprintf('Trajetória 2 (Otimizada): Distância = %.2f m', d_max_2)}, ...
        'Location', 'Best');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARTE 2 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A)

% Limites das variáveis
lbga = [0.1, deg2rad(10.1)];
ubga = [2.9, deg2rad(89.9)];

% Opções do algoritmo genético
options = optimoptions('ga', ...
    'PopulationSize', 100, ...          % Tamanho da população
    'MaxGenerations', 200, ...          % Número máximo de gerações
    'CrossoverFraction', 0.8, ...       % Fração de cruzamento
    'Display', 'iter', ...              % Progresso no terminal
    'PlotFcn', {@gaplotbestf});         % Gráfico da convergência

% GA
[nvars, A, b, Aeq, beq, nonlcon] = deal(2, [], [], [], [], []);
[x_optga, fvalga] = ga(@obj_foguete, nvars, A, b, Aeq, beq, lbga, ubga, nonlcon, options);

% Resultado final
m_agua_optga = x_optga(1);  % Massa de água otimizada
theta_optga = rad2deg(x_optga(2));  % Ângulo otimizado (em graus)
dist_maxga = -fvalga;  % Distância máxima alcançada (positivo)

fprintf('Solução Ótima da GA:\n');
fprintf('- Massa de água ótima: %.3f kg\n', m_agua_optga);
fprintf('- Ângulo ótimo: %.2f graus\n', theta_optga);
fprintf('- Distância máxima: %.2f m\n', dist_maxga);

% Simulação para o gráfico da trajetória
[~, x_traj_ga, y_traj_ga] = foguete_dist_max(m_agua_optga, deg2rad(theta_optga));

% Gráfico da trajetória otimizada
figure;
plot(x_traj_ga, y_traj_ga, 'g-', 'LineWidth', 1.5);
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Trajetória do Foguete Otimizado');
grid on;

text(0.02 * max(x_traj_ga), 0.95 * max(y_traj_ga), ...
    sprintf('Massa água = %.3f kg\nÂngulo = %.2f°\nDistância = %.2f m', ...
    m_agua_optga, theta_optga, dist_maxga), ...
    'FontSize', 10, 'BackgroundColor', 'white');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% C)

% Comparação GA x FMINCON
figure;
hold on;
plot(x_traj_ga, y_traj_ga, 'g-', 'LineWidth', 1.5); % Trajetória GA em verde
plot(x_traj_2, y_traj_2, 'r-', 'LineWidth', 1.5); % Trajetória FMINCON em vermelho
hold off;

% Configurações
xlabel('Distância Horizontal (m)');
ylabel('Altura (m)');
title('Comparação de Trajetórias do Foguete');
grid on;

% Legenda
legend({sprintf('Trajetória 1 (GA): Distância = %.2f m', dist_maxga), ...
        sprintf('Trajetória 2 (FMINCON): Distância = %.2f m', d_max_2)}, ...
        'Location', 'Best');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% D)