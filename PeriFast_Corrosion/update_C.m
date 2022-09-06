function [C,chi_l,chi_s] = update_C(corrosion_type,dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer)
if(corrosion_type == 0)
    [C,chi_l,chi_s] = uniform_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer);
else
    [C,chi_l,chi_s] = pitting_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer);
end
end

function [C,chi_l,chi_s] = pitting_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer)
% Update mask functions for liquid domain, salt layer, and liquid domain:
chi_l (C < C_sat) = 1; %find liquid node
chi_l_pit = zeros(Nx,Ny,Nz);
chi_l_pit(chi_l==1 & chi_N==1) = 1;
chi_salt = zeros(Nx,Ny,Nz);
if(has_salt_layer==1)
    chi_salt(C >= C_sat & chi_l_pit==1) = 1;
end
chi_s = 1 - chi_l;

C = chi.*(C + dt*((chi_l).*ifftn(convolveInFourier_diff(fftn(C.*(chi_l)))) -...
    ((chi_l).*C).*ifftn(convolveInFourier_diff(fftn(chi_l))) + ...
    (chi_l_pit-chi_salt).*ifftn(convolveInFourier_corr(fftn(chi_s))) -...
    chi_s.*ifftn(convolveInFourier_corr(fftn(chi_l_pit-chi_salt)))))+ (1 - chi).*C_w;

end

function [C,chi_l,chi_s] = uniform_corrosion_time_integration(dt,C,C_w,C_sat,chi_l,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer)
% Update mask functions for liquid domain, salt layer, and liquid domain:
chi_l (C < C_sat) = 1; %find liquid node
chi_salt = zeros(Nx,Ny,Nz);
if(has_salt_layer==1)
    chi_salt(C >= C_sat & chi_l==1) = 1;
end
chi_s = 1 - chi_l;

C = chi.*(C + dt*((chi_l).*ifftn(convolveInFourier_diff(fftn(C.*(chi_l)))) -...
    ((chi_l).*C).*ifftn(convolveInFourier_diff(fftn(chi_l))) + ...
    (chi_l-chi_salt).*ifftn(convolveInFourier_corr(fftn(chi_s))) -...
    chi_s.*ifftn(convolveInFourier_corr(fftn(chi_l-chi_salt)))))+ (1 - chi).*C_w;

end