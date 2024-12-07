%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Só juntou as duas funções "fmincon1.m" e "fmincon2.m que podem ser 
% encontradas na mesma pasta
% O equacionamento foi baseado todo no arquivo "test.m"
% Cálculos baseados na apostila do professor Marcelo Ramos
% Ver teorias referentes a Estabilidade Inicial e Adição de Carga

% Parâmetros de entrada
W_min = 30;         % Valor mínimo de W (kg)
W_max_input = 120;  % Valor máximo de W (kg)
theta_max = 8;      % Ângulo máximo (graus)
L = 1.5;            % Comprimento do pedalinho (m)

% Chamar as duas funções
W_max1 = peso_maximo_fmincon(W_min, W_max_input, theta_max);
[W_max2, d_opt] = peso_maximo_fmincon2(W_min, W_max_input, theta_max, L);

% Exibir os resultados das duas otimizações
fprintf('\nResultado da otimização para W somente:\n');
fprintf('W_max1 = %.2f kg\n', W_max1);

fprintf('\nResultado da otimização para W e d:\n');
fprintf('W_max2 = %.2f kg\n', W_max2);
fprintf('d_opt = %.2f m\n', d_opt);

% Função de otimização para W somente
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
end

% Função de restrições não lineares (para W somente)
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

% Função de otimização para W e d
function [W_max, d_opt] = peso_maximo_fmincon2(W_min, W_max_input, theta_max, L)
    % Parâmetros dados
    h = 0.3;    % Lados do casco (m)
    H = 1.8;    % Altura do aluno (m)
    d = 0.375;  % Distância do peso (m) (valor inicial)
    C = 1.5;    % Comprimento do pedalinho (m)
    T = 0.15;   % Calado do pedalinho (m)

    % Parâmetros para equacionamento
    VolCasco = C * h * T;           % Volume por casco (m^3)
    Vol = 2 * VolCasco;             % Volume total do pedalinho (m^3)
    PesoEspec = 1;                  % Peso específico (t/m^3)
    Deslocamento = PesoEspec * Vol; % Deslocamento do pedalinho (t)
    
    % Definir a função objetivo (minimizar -W)
    objective = @(x) -x(1); % x(1) será W

    % Restrições
    nonlcon = @(x) restricoes2(x, L, h, H, C, T, Vol, Deslocamento, theta_max);

    % Limitações no valor de W e d
    lb = [W_min, 0];   % Limite inferior para W e d (d >= 0)
    ub = [W_max_input, L/2]; % Limite superior para W e d (d <= L/2)

    % Chamar fmincon para minimizar a função objetivo
    options = optimoptions('fmincon', 'Display', 'off');
    x_opt = fmincon(objective, [W_min, d], [], [], [], [], lb, ub, nonlcon, options);
    
    % Extrair o valor otimizado de W e d
    W_max = x_opt(1);
    d_opt = x_opt(2);
end

% Função de restrições não lineares (para W e d)
function [c, ceq] = restricoes2(x, L, h, H, C, T, Vol, Deslocamento, theta_max)
    % Extrair W e d do vetor x
    W = x(1); % Peso (kg)
    d = x(2); % Distância do peso (m)

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
