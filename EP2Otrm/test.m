%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problema 1
Wmin = (30)/1000; % Peso Mínimo do Aluno (t)
Wmax = (200)/1000; % Peso Máximo do Aluno (t)
thetamax = deg2rad(8); % Angulo de Emborque (°)
W_max = peso_maximo(Wmin, Wmax, thetamax);

fprintf('\n O peso máximo permitido a distância d = 0.375 m é de %.5f kg \n', W_max);
function [W_max] = peso_maximo(Wmin, Wmax, thetamax)
    % Parâmetros dados
    L = 1.5;    % Dist Cascos (m)
    h = 0.3;    % Lados do Casco (m)
    H = 1.8;    % Altura do Aluno (m)
    d = 0.375;  % Dist do Peso (m)


    % Parâmetros arbitrários
    C = 1.5;    % Comprimento do Pedalinho (m)
    T = 0.15;   % Calado do Pedalinho (m)

    % Parâmetros para equacionamento
    VolCasco = C * h * T;           % Volume por Casco (m^3)
    Vol = 2 * VolCasco;             % Volume Total do Pedalinho (m^3)
    PesoEspec = 1;                  % Peso Especifico (t/m^3)
    Deslocamento = PesoEspec * Vol; % Deslocamento do Pedalinho (t)
    
    % Cálculo das alturas e momentos
    % Retirados das teorias de Adição de Carga e Estabilidade Inicial
    % de: Apostila do Professor Marcelo Ramos

    W_max = 0; % Armazena W
    for W = Wmin:0.1:Wmax % Intervalo de 30 a 120 kg
        %W = W/1000; % kg -> t
        KG = ((T/2)*Deslocamento + ((0.5*H)*W))/(W + Deslocamento);   % Altura do CG em relacao a linha de base, considerando a carga (m)
        KB = T/2;   % Altura do CB em relacao a linha de base (m)
        It = 2 * ((C * h^3)/12 + (h * C) * (L/2)^2); % Momento de Inércia do Catamara
        BMt = It/Vol; % BM transversal do Pedalinho
        GMt = KB + BMt - KG; % GM transversal do Pedalinho
        theta = atan((W*d)/(Deslocamento*GMt)); % Valor do Angulo de Banda


        if GMt > 0 && theta <= thetamax % Condição de Estabilidade && Não Emborque
            fprintf('Estável \n');
            fprintf('Theta = %.4f\n', rad2deg(theta));
            fprintf('GMt = %.4f\n', GMt);
            fprintf('It = %.4f\n', It);
            W_max = max(W_max, W * 1000);
            
        else
            fprintf('GMt = %.4f\n', GMt);
            fprintf('Theta = %.4f\n', rad2deg(theta));
            fprintf('Emborca \n');
        end
        
    end
    
    % Display results with formatted output
    fprintf('Resultados finais \n');
    fprintf('It final = %.4f\n', It);
    fprintf('BMt final = %.4f\n', BMt);
    fprintf('GMt final = %.4f\n', GMt);
    fprintf('Theta final = %.4f\n', rad2deg(theta));
    fprintf('W_max final = %.4f\n', W_max);
end