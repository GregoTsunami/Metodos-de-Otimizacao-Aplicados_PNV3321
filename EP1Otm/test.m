function d_max = foguete_distancia_maxima(m_agua, theta)
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
    theta = deg2rad(theta); % AnguloRampaInicial (rad)
    t_k = 0; % TempoInicial (s)
    d_k = 0; % DistXInicial (m)
    h_k = hr; % AlturaInicial (m)
    Ux_k = 0; % VelocidadeXInicial (m/s)
    Uy_k = 0; % VelocidadeYInicial (m/s)
    P_k = P; % PressaoInternaInicial (Pa)
    m_agua_k = m_agua; % MassaAguaInicial (kg)
    
    % Simulação do movimento
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
        
        % Normal e Acelerações
        if (h_k < hr) && (d_k < hr / tan(theta)) && (Uy_k > 0)
            N_k = g * (mg + m_agua_k1) * cos(theta);
            ax_k = ((E_k - Fa_k) * cos(theta) - N_k * sin(theta)) / (m_agua_k1 + mg);
            ay_k = ((E_k - Fa_k) * sin(theta) + N_k * cos(theta)) / (m_agua_k1 + mg) - g;
        else
            N_k = 0;
            ax_k = ((E_k - Fa_k) * cos(theta)) / (m_agua_k1 + mg);
            ay_k = ((E_k - Fa_k) * sin(theta)) / (m_agua_k1 + mg) - g;
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





m_agua = 0.5; % Massa inicial de água (kg)
theta = 30; % Ângulo da rampa (graus)

distancia_maxima = foguete_distancia_maxima(m_agua, theta);
fprintf('A distância máxima horizontal é %.5f metros.\n', distancia_maxima);
