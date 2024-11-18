function empuxo = empuxo(P, Patm, Ab)

    global theta m_agua dt
    global mg Vg Ab Af P hr rho_agua rho_ar Patm Ca g
    global t_k d_k h_k Ux_k Uy_k ax_k ay_k U_agua_k P_k m_agua_k
    
    empuxo = max((P_k-Patm)*Ab,0);

end