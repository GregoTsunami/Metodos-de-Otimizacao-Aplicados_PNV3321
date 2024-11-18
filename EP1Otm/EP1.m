% Otimiza EP1

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Chute Inicial
global theta m_agua dt
m_agua = 1; % MassaAguaInicial (kg)
theta = 60; % AnguloRampa (°)
dt = 0.01; % PassoTempo (s)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parâmetros
global mg Vg Ab Af P hr rho_agua rho_ar Patm Ca g

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Condições Iniciais
global theta_k t_k d_k h_k Ux_k Uy_k ax_k ay_k U_agua_k P_k m_agua_k

theta_k = deg2rad(theta); % AnguloRampaInicial (rad)
t_k = 0; % TempoInicial (s)
d_k = 0; % DistXInicial (m)
h_k = hr; % AlturaInicial (m)
Ux_k = 0; % VelocidadeXInicial (m/s)
Uy_k = 0; % VelocidadeYInicial (m/s)
ax_k = 0; % AceleracaoXInicial (m/s^2) 
ay_k = 0; % AceleracaoYInicial (m/s^2)
U_agua_k = 0; % VelocidadeAguaInicial (m/s)
P_k = 0; % PressaoInternaInicial (Pa)
m_agua_k = m_agua; % MassaAguaInicial (kg)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Teste




%E = empuxo(P, Patm, Ab);
%Fa = arrasto(Ca, rho_ar, Ux_k, Uy_k, Af);
dmax = dist_maxima_foguete(m_agua, theta);
fprintf('A distância máxima horizontal é %.5f metros.\n', dmax);


%disp(E);
%disp(Fa);
%disp(dmax);
