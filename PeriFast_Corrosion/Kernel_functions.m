% Kernel functions used in corrosion:
% Kernel function for the diffusion in 3D:
kernel_diff = @(x1,x2,x3) 9*K/(2*pi*delta^3) * 1./(x1.^2+x2.^2+x3.^2);
% Kernel function for corrosion in 3D:
kernel_corr = @(x1,x2,x3) 3*q/(pi*delta^3) * 1./(sqrt(x1.^2+x2.^2+x3.^2));

% Descritized kernel diffusion and corrosion
mu_diff = kernel_diff(X,Y,Z); %kernel for diffusion in liquid
mu_diff = mu_diff.*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta); % zero out of the horizon
mu_diff(X==0 & Y==0 & Z==0) = 0; % zero out the singularity

mu_corr = kernel_corr(X,Y,Z); %kernel for corrosion (solid to liquid)
mu_corr = mu_corr.*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta); % zero out of the horizon
mu_corr(X==0 & Y==0 & Z==0) = 0; % zero out the singularity

% muS_diff is "shifted mu_diff". mu_diff should be shifted by x_min, y_min, and z_min in
% x, y, and z directions respectively.
muS_diff = zeros(Nx,Ny,Nz);
muS_diff(1:Nx/2, 1:Ny/2, 1:Nz/2) = mu_diff(Nx/2+1:Nx, Ny/2+1:Ny, Nz/2+1:Nz);
muS_diff(1:Nx/2, 1:Ny/2, Nz/2+1:Nz) = mu_diff(Nx/2+1:Nx, Ny/2+1:Ny, 1:Nz/2);
muS_diff(Nx/2+1:Nx, Ny/2+1:Ny, 1:Nz/2) = mu_diff(1:Nx/2, 1:Ny/2, Nz/2+1:Nz);
muS_diff(Nx/2+1:Nx, Ny/2+1:Ny, Nz/2+1:Nz) = mu_diff(1:Nx/2, 1:Ny/2, 1:Nz/2);
muS_diff(Nx/2+1:Nx, 1:Ny/2, 1:Nz/2) = mu_diff(1:Nx/2, Ny/2+1:Ny, Nz/2+1:Nz);
muS_diff(Nx/2+1:Nx, 1:Ny/2, Nz/2+1:Nz) = mu_diff(1:Nx/2, Ny/2+1:Ny, 1:Nz/2);
muS_diff(1:Nx/2, Ny/2+1:Ny, 1:Nz/2) = mu_diff(Nx/2+1:Nx, 1:Ny/2, Nz/2+1:Nz);
muS_diff(1:Nx/2, Ny/2+1:Ny, Nz/2+1:Nz) = mu_diff(Nx/2+1:Nx, 1:Ny/2, 1:Nz/2);
muS_diff_hat = fftn(muS_diff);
% muS_corr is "shifted mu_corr"
muS_corr = zeros(Nx,Ny,Nz);
muS_corr(1:Nx/2, 1:Ny/2, 1:Nz/2) = mu_corr(Nx/2+1:Nx, Ny/2+1:Ny, Nz/2+1:Nz);
muS_corr(1:Nx/2, 1:Ny/2, Nz/2+1:Nz) = mu_corr(Nx/2+1:Nx, Ny/2+1:Ny, 1:Nz/2);
muS_corr(Nx/2+1:Nx, Ny/2+1:Ny, 1:Nz/2) = mu_corr(1:Nx/2, 1:Ny/2, Nz/2+1:Nz);
muS_corr(Nx/2+1:Nx, Ny/2+1:Ny, Nz/2+1:Nz) = mu_corr(1:Nx/2, 1:Ny/2, 1:Nz/2);
muS_corr(Nx/2+1:Nx, 1:Ny/2, 1:Nz/2) = mu_corr(1:Nx/2, Ny/2+1:Ny, Nz/2+1:Nz);
muS_corr(Nx/2+1:Nx, 1:Ny/2, Nz/2+1:Nz) = mu_corr(1:Nx/2, Ny/2+1:Ny, 1:Nz/2);
muS_corr(1:Nx/2, Ny/2+1:Ny, 1:Nz/2) = mu_corr(Nx/2+1:Nx, 1:Ny/2, Nz/2+1:Nz);
muS_corr(1:Nx/2, Ny/2+1:Ny, Nz/2+1:Nz) = mu_corr(Nx/2+1:Nx, 1:Ny/2, 1:Nz/2);
muS_corr_hat = fftn(muS_corr);
% Mutiplication function to compute convolution integrals in Fourier Space
convolveInFourier_diff = @(m) muS_diff_hat.*m*dx*dy*dz;
convolveInFourier_corr = @(m) muS_corr_hat.*m*dx*dy*dz;