    % Update mask functions for liquid domain, salt layer, and liquid domain:
    chi_l (C < C_sat) = 1; %find liquid node
    chi_l_pit(chi_l==1 & chi_N==1) = 1;
    
    %find salt node
    chi_salt = zeros(Nx,Ny,Nz);
    chi_salt(C >= C_sat & chi_l_pit==1) = 1;
    
    chi_s = 1 - chi_l;