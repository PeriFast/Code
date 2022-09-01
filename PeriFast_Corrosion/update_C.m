if(corrosion_type == 0)
    uniform_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr);
else
    pitting_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr);
end

function [C] = pitting_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr)
% Update mask functions for liquid domain, salt layer, and liquid domain:
chi_l (C < C_sat) = 1; %find liquid node
chi_l_pit = zeros(Nx,Ny,Nz);
chi_l_pit(chi_l==1 & chi_N==1) = 1;
chi_salt = zeros(Nx,Ny,Nz);
chi_salt(C >= C_sat & chi_l_pit==1) = 1;
chi_s = 1 - chi_l;

C = chi.*(C+ + dt*((chi_l).*ifftn(convolveInFourier_diff(fftn(C.*(chi_l)))) -...
    ((chi_l).*C).*ifftn(convolveInFourier_diff(fftn(chi_l))) + ...
    (chi_l_pit-chi_salt).*ifftn(convolveInFourier_corr(fftn(chi_s))) -...
    chi_s.*ifftn(convolveInFourier_corr(fftn(chi_l_pit-chi_salt)))))+ (1 - chi).*C_w;

end

function [C] = uniform_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr)
% Update mask functions for liquid domain, salt layer, and liquid domain:
chi_l (C < C_sat) = 1; %find liquid node
chi_salt = zeros(Nx,Ny,Nz);
chi_salt(C >= C_sat & chi_l==1) = 1;
chi_s = 1 - chi_l;

C = chi.*(C+ + dt*((chi_l).*ifftn(convolveInFourier_diff(fftn(C.*(chi_l)))) -...
    ((chi_l).*C).*ifftn(convolveInFourier_diff(fftn(chi_l))) + ...
    (chi_l-chi_salt).*ifftn(convolveInFourier_corr(fftn(chi_s))) -...
    chi_s.*ifftn(convolveInFourier_corr(fftn(chi_l-chi_salt)))))+ (1 - chi).*C_w;

end