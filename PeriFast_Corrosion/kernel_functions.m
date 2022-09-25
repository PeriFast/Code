% Kernel functions used in corrosion:
% the center of box
x_c = x_min_T + Lx_T/2;
y_c = y_min_T + Ly_T/2;
z_c = z_min_T + Lz_T/2;
% Kernel function for the diffusion in 3D:
kernel_diff = @(x1,x2,x3) 9*K/(2*pi*delta^3) * 1./(x1.^2+x2.^2+x3.^2) .*(sqrt(x1.^2 + x2.^2 + x3.^2) <= delta);
% Kernel function for corrosion in 3D:
kernel_corr = @(x1,x2,x3) 3*q/(pi*delta^3) * 1./(sqrt(x1.^2+x2.^2+x3.^2)) .*(sqrt(x1.^2 + x2.^2 + x3.^2) <= delta);

% Descritized kernel diffusion and corrosion
mu_diff = kernel_diff(X - x_c, Y - y_c, Z - z_c); %kernel for diffusion in liquid
mu_diff(X==x_c & Y==y_c & Z==z_c) = 0; % zero out the singularity
beta_diff = sum(sum(sum(mu_diff.*(dx*dy*dz))));
muS_diff_hat = fftn(fftshift(mu_diff)); % adjust kernel functions on the periodic box T

mu_corr = kernel_corr(X - x_c, Y - y_c, Z - z_c); %kernel for corrosion (solid to liquid)
mu_corr(X==x_c & Y==y_c & Z==z_c) = 0; % zero out the singularity
beta_corr = sum(sum(sum(mu_corr.*(dx*dy*dz))));
muS_corr_hat = fftn(fftshift(mu_corr));

stability_check(dt,beta_diff,beta_corr,t_max,corrosion_type, C_sat);
% Mutiplication function to compute convolution integrals in Fourier Space
convolveInFourier_diff = @(m) muS_diff_hat.*m*dx*dy*dz;
convolveInFourier_corr = @(m) muS_corr_hat.*m*dx*dy*dz;

function stability_check(dt,beta_diff,beta_corr,t_max,corrosion_type, C_sat)
if(dt > 1/beta_diff && (corrosion_type == 0 || corrosion_type == 2)) %for corrosion types that consider diffusion
    error('dt does not meet the stability condition. Please set dt less than %d, see https://doi.org/10.1016/j.cma.2020.113633',1/beta_diff);
end

if(dt > C_sat/beta_corr && corrosion_type == 1) %for activation-control corrosion that do not consider diffusion
    error('dt does not meet the stability condition. Please set dt less than %d, see https://doi.org/10.1016/j.cma.2020.113633',C_sat/beta_corr);
end

if(dt < 0)
    error('dt must be positive');
end
if(dt > t_max)
    error('dt can not large than the total time');
end
end