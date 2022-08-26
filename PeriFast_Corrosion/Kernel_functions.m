% Kernel functions used in corrosion:
% Kernel function for the diffusion in 3D:
kernel_diff = @(x1,x2,x3) 9*K/(2*pi*delta^3) * 1./(x1.^2+x2.^2+x3.^2);
% Kernel function for corrosion in 3D:
kernel_corr = @(x1,x2,x3) 3*q/(pi*delta^3) * 1./(sqrt(x1.^2+x2.^2+x3.^2));

% Descritized kernel diffusion and corrosion
mu_diff = kernel_diff(X,Y,Z); %kernel for diffusion in liquid
mu_diff = mu_diff.*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta); % zero out of the horizon
mu_diff(X==0 & Y==0 & Z==0) = 0; % zero out the singularity
muS_diff_hat = fftn(fftshift(mu_diff)); % adjust kernel functions on the periodic box T

mu_corr = kernel_corr(X,Y,Z); %kernel for corrosion (solid to liquid)
mu_corr = mu_corr.*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta); % zero out of the horizon
mu_corr(X==0 & Y==0 & Z==0) = 0; % zero out the singularity
muS_corr_hat = fftn(fftshift(mu_corr));

% Mutiplication function to compute convolution integrals in Fourier Space
convolveInFourier_diff = @(m) muS_diff_hat.*m*dx*dy*dz;
convolveInFourier_corr = @(m) muS_corr_hat.*m*dx*dy*dz;