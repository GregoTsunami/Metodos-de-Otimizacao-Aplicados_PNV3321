W_min = 30;       % Valor mínimo de W (kg)
W_max_input = 120; % Valor máximo de W (kg)
theta_max = 8;    % Ângulo máximo (graus)

W_max = peso_maximo_fmincon(W_min, W_max_input, theta_max);


function W_max = peso_maximo_fmincon(W_min, W_max_input, theta_max)
    % Parâmetros dados
    L = 1.5;    % Distância entre os cascos (m)
    h = 0.3;    % Lados do casco (m)
    H = 1.8;    % Altura do aluno (m)
    d = 0.375;  % Distância do peso (m)

    % Parâmetros arbitrários
    C = 1.5;    % Comprimento do pedalinho (m)
    T = 0.15;   % Calado do pedalinho (m)

    % Parâmetros para equacionamento
    VolCasco = C * h * T;           % Volume por casco (m^3)
    Vol = 2 * VolCasco;             % Volume total do pedalinho (m^3)
    PesoEspec = 1;                  % Peso específico (t/m^3)
    Deslocamento = PesoEspec * Vol; % Deslocamento do pedalinho (t)
    
    % Definir a função objetivo (minimizar -W)
    objective = @(W) -W;

    % Restrições
    nonlcon = @(W) restricoes(W, L, h, H, d, C, T, Vol, Deslocamento, theta_max);

    % Limitações no valor de W
    lb = W_min;  % Limite inferior para W (em kg)
    ub = W_max_input;  % Limite superior para W (em kg)

    % Chamar fmincon para minimizar a função objetivo
    options = optimoptions('fmincon', 'Display', 'off');
    W_max = fmincon(objective, W_min, [], [], [], [], lb, ub, nonlcon, options);
    
    % Exibir o resultado
    fprintf('W_max = %.2f kg\n', W_max);
end

% Função de restrições não lineares
function [c, ceq] = restricoes(W, L, h, H, d, C, T, Vol, Deslocamento, theta_max)
    % Converte W de kg para toneladas (t)
    W_t = W / 1000;
    
    % Cálculo das alturas e momentos
    KG = ((T / 2) * Deslocamento + (0.5*H * W_t)) / (W_t + Deslocamento);  % Altura do CG (m)
    KB = T / 2;  % Altura do CB (m)
    It = 2 * ((C * h^3) / 12 + (h * C) * (L / 2)^2); % Momento de inércia
    BMt = It / Vol; % Altura metacêntrica
    GMt = KB + BMt - KG; % Altura metacêntrica
    theta = atan((W_t * d) / (Deslocamento * GMt)); % Ângulo de inclinação em radianos

    % Restrições: GMt > 0 e theta <= theta_max
    c(1) = -GMt;  % GMt deve ser maior que 0, logo c(1) <= 0
    c(2) = theta - deg2rad(theta_max); % theta deve ser menor ou igual a theta_max
    ceq = [];  % Não há restrições de igualdade

end
