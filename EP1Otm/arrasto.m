function arrasto = arrasto(Ca, rho_ar, Ux_k, Uy_k, Af)

    global theta m_agua dt
    global mg Vg Ab Af P hr rho_agua rho_ar Patm Ca g
    global t_k d_k h_k Ux_k Uy_k ax_k ay_k U_agua_k P_k m_agua_k
    
    arrasto = (1/2)*Ca*rho_ar*(((Ux_k)^2)+(Uy_k)^2)*Af;

end