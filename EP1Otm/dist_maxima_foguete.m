function d_max = dist_maxima_foguete(m_agua, theta)

    global theta m_agua dt
    global mg Vg Ab Af P hr rho_agua rho_ar Patm Ca g
    global theta_k t_k d_k h_k Ux_k Uy_k ax_k ay_k U_agua_k P_k m_agua_k

    while h_k >= 0
        % Tempo
        t_k = t_k + dt;
        
        % Distancia X Foguete
        d_k = d_k + Ux_k*dt + (ax_k/2)*dt^2;

        % Altura Y Foguete
        h_k = h_k + Uy_k*dt + (ay_k/2)*dt^2;

        % Pressão Interna
        if m_agua > 0
            P_k = P_k*((Vg-m_agua)/rho_agua)/((Vg-m_agua)/rho_agua);
        else
            P_k = 0;
        end

        % Velocidade Agua
        if P_k-Patm > 0
            U_agua_k = sqrt(2*(P_k-Patm)/rho_agua);
        else
            U_agua_k = 0;
        end
        
        % Massa Agua
        m_agua_k = max(m_agua_k - U_agua_k*Ab*rho_agua*dt,0);

        % Empuxo
        E_k = empuxo(P_k, Patm, Ab);

        % Força Arrasto
        Fa_k = arrasto(Ca, rho_ar, Ux_k, Uy_k, Af);

        % Velocidade X Foguete
        if h_k >= 0
            Ux_k = Ux_k + ax_k*dt;
        else
            Ux_k = 0;
        end

        % Velocidade Y Foguete
        if h_k >= 0
            Uy_k = Uy_k + ay_k*dt;
        else
            Uy_k = 0;
        end

        % Componente Normal
        if (h_k < hr) && (d_k < hr/tan(theta)) && (Uy_k > 0)
            N_k = g*(mg + m_agua_k)*cos(theta);
        else
            N_k = 0;
        end

        % Aceleração X Foguete
        if (h_k < hr) && (d_k < hr/tan(theta)) && (Uy_k > 0)
            ax_k = ((E_k - Fa_k)*cos(theta)-N_k*sin(theta))/(m_agua_k + mg);
        else
            ax_k = ((E_k - Fa_k)*cos(theta))/(m_agua_k + mg);
        end
       
        % Aceleração Y Foguete
        if (h_k < hr) && (d_k < hr/tan(theta)) && (Uy_k > 0)
            ay_k = ((E_k - Fa_k)*sin(theta)-N_k*cos(theta))/(m_agua_k + mg) - g;
        else
            ay_k = ((E_k - Fa_k)*sin(theta))/(m_agua_k + mg) - g;
        end

        % Ângulo Foguete
        if (h_k < hr) && (d_k < hr/tan(theta)) && (Uy_k > 0)
            theta_k = theta;
        else
            theta_k = atan((Uy_k/Ux_k));
        end

    end
    d_max = d_k;

end