    % Update mask functions for liquid domain, salt layer, and liquid domain:
    %chi_l = zeros(Nx,Ny,Nz);
    chi_l (C < C_sat) = 1; %find liquid node
    chi_l_pit(chi_l==1 & chi_N==1) = 1;
    
    %find salt node
    chi_salt = zeros(Nx,Ny,Nz);
    chi_con = zeros(Nx,Ny,Nz);
    chi_con(chi_l==1 & C>=C_sat) = 1;
    chi_salt_tmp = ifftn(convolveInFourier_salt(fftn(chi.*chi_con)));
    chi_salt(chi_salt_tmp>=1 & chi_l==0) = 1;
    
    chi_s = 1 - chi_l-chi_salt;