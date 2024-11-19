function d_max = foguete_dist_max(m_agua, theta)
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
    dt = 0.01; % PassoTempo (s)
    
    % Condições iniciais
    t_k = 0; % TempoInicial (s)
    d_k = 0; % DistXInicial (m)
    h_k = hr; % AlturaInicial (m)
    Ux_k = 0.1; % VelocidadeXInicial (m/s)
    Uy_k = 0.1; % VelocidadeYInicial (m/s)
    P_k = P; % PressaoInternaInicial (Pa)
    m_agua_k = m_agua; % MassaAguaInicial (kg)
    theta_k = theta; %AnguloFoguete (°)
    
    % Simulação
    while h_k >= 0
        % Velocidade e Massa de água
        if P_k > Patm
            U_agua_k = sqrt(2 * (P_k - Patm) / rho_agua);
        else
            U_agua_k = 0;
        end
        
        m_agua_k1 = max(m_agua_k - U_agua_k * Ab * rho_agua * dt, 0); % m_agua^(k-1)
        
        % Pressão
        if m_agua_k > 0
            P_k1 = P_k * (Vg - m_agua_k / rho_agua) / (Vg - m_agua_k1 / rho_agua);
        else
            P_k1 = Patm; % Após ejeção total da água, pressão igual à atmosférica
        end
        
        % Empuxo
        E_k = max((P_k1 - Patm) * Ab, 0);
        
        % Arrasto
        Fa_k = 0.5 * Ca * rho_ar * ((Ux_k)^2 + (Uy_k)^2) * Af;
        
        % Normal, Acelerações e Ângulo Foguete
        if (h_k < hr) && (d_k < hr / tan(theta)) && (Uy_k > 0)
            theta_k = theta*(pi/180);
            N_k = g * (mg + m_agua_k1) * cos(theta_k);
            ax_k = ((E_k - Fa_k) * cos(theta_k) - N_k * sin(theta_k)) / (m_agua_k1 + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_k) + N_k * cos(theta_k)) / (m_agua_k1 + mg) - g;
        else
            N_k = 0;
            if Ux_k~= 0
                theta_k = atan(Uy_k/Ux_k);
            else
                theta_k = theta*(pi/180);
            end
            ax_k = ((E_k - Fa_k) * cos(theta_k)) / (m_agua_k1 + mg);
            ay_k = ((E_k - Fa_k) * sin(theta_k)) / (m_agua_k1 + mg) - g;
        end
        
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
        
        % Att Variáveis
        m_agua_k = m_agua_k1;
        P_k = P_k1;
        
        % Tempo
        t_k = t_k + dt;
    end

    
    % Distância Máxima Horizontal
    d_max = d_k;
end



% A)
% Chutes Iniciais
%m_agua = 0.5; % Massa inicial de água (kg) 
%theta = 45; % Ângulo da rampa (graus)

%dist_max = foguete_dist_max(m_agua, theta);
%fprintf('A distância máxima horizontal é %.5f metros.\n', dist_max);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% B)

% Função Objetivo:
% Maximizar d_max(m_agua, theta)


% Variávveis e Restrições
% m_agua: [0.1, 3.0] (0 < m_agua < rho_agua*Vg)
% theta: [0, 90] ° (0 < theta < 90°)
%P_k - Patm > 0 para ejetar


% Intervalo para Variáveis

m_agua_min = 0.1;
m_agua_max = 2.9; %rho_agua*Vg

theta_min = 10;
theta_max = 89.9;

m_agua_values = linspace(m_agua_min, m_agua_max, 100);
theta_values = deg2rad(linspace(theta_min, theta_max, 100));


% Teste pra ver melhor valor
melhor_dist = -inf;
melhor_m_agua = 0;
melhor_theta = 0;

for m_agua = m_agua_values
    for theta = theta_values
        dist = foguete_dist_max(m_agua, theta);
        if dist > melhor_dist
            melhor_dist = dist;
            melhor_m_agua = m_agua;
            melhor_theta = theta;
        end
    end
end
fprintf('Melhor massa de água: %.5f kg\n', melhor_m_agua);
fprintf('Melhor ângulo: %.5f rad \n', melhor_theta)
fprintf('Melhor distância: %.5f m\n', melhor_dist);

% A partir daqui não sei o que ta acontecendo
% Plot 3D
[Theta, M_agua] = meshgrid(theta_values, m_agua_values);
fobj_values = zeros(length(m_agua_values), length(theta_values));

for i = 1:length(m_agua_values)
    for j = 1:length(theta_values)
        fobj_values(i, j) = foguete_dist_max(m_agua_values(i), theta_values(j));
    end
end

figure;
surf(Theta, M_agua, fobj_values);
xlabel('\theta (graus)');
ylabel('m_{agua} (kg)');
zlabel('Distância Máxima (m)');
title('Superfície da Função Objetivo: m_{agua} × \theta × f_{obj}');
grid on;