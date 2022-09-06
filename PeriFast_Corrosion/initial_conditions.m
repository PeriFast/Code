% Initial condition and mask functions
% Discretized initial condition u(x,0):
C0 = zeros(Nx,Ny,Nz);
C0(chi_N == 1) = C_solid; %Big N concentration equal to C_solid

% Generate initial spherical pits, only for pitting corrosion
if(corrosion_type == 1)
    total_pits_no = 20; % total number of initial pits
    for i = 1:total_pits_no
        % randomly generate pits center coordinates, under uniform distribution
        pit_x = (-1+2*rand)*x_max; % x location from -75um to 75um
        pit_y = (-1+2*rand)*y_max; % y location from -60um to 60um
        pit_z = 18e-6 + 5e-6*rand; % z coordinate of pit center, from 18um to 23um
        % randomly generate pits radius, from 2 to 4 um, under uniform distribution
        pit_r = 2e-6 + rand*2e-6; %the initial pit radius, 2 to 4 um
        C0((X-pit_x).^2+(Y-pit_y).^2+(Z-pit_z).^2 <= pit_r^2) = 0.9*C_sat; %initialize the pits that filled with solution
    end
    C0(chi_N == 0) = 0;
end

% Construct Mask function (chi_l) for liquid domain:
chi_l = zeros(Nx,Ny,Nz);
chi_l_pit = zeros(Nx,Ny,Nz);
chi_l (C0 < C_sat) = 1; %find liquid nodes
chi_l_pit(chi_l==1 & chi_N==1) = 1; %find the liquid nodes inside pits
% Construct Mask function for salt layer
chi_salt = zeros(Nx,Ny,Nz);
% Construct Mask function (chi_s) for solid domain
chi_s = 1 - chi_l;
