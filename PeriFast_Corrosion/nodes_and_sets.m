% The big N and surrounding liquid domain dimensions
% big N solid is in a 150*120*40 um box
% the liquid domain has a 2 horizon size thickness
delta = 4e-6; % horizon size, unit in m
Ldx = 150e-6+2*delta; % physical domain length in x direction
Ldy = 120e-6+2*delta; % physical domain length in y direction
Ldz = 40e-6+2*delta; % physical domain length in z direction
x_min = -Ldx/2;
x_max = Ldx/2;
y_min = -Ldy/2;
y_max = Ldy/2;
z_min = -Ldz/2;
z_max = Ldz/2;
% One periodic Domain (T)
% extend 1 horizon size at each end, in order to avoid wrap-up 
% and use ficitious node method to apply boundary conditions
extension = 1.0*delta;
x_min_T = x_min - extension;
x_max_T = x_max + extension;
y_min_T = y_min - extension;
y_max_T = y_max + extension;
z_min_T = z_min - extension;
z_max_T = z_max + extension;
% the period box dimension
Lx_T = x_max_T - x_min_T;
Ly_T = y_max_T - y_min_T;
Lz_T = z_max_T - z_min_T;

% Discretize the domain
Nx = 2^8; % resolution in x (Best for FFT to use a power of 2)
Ny = 2^8; % resolution in y
Nz = 2^6; % resolution in z
dx = Lx_T/Nx; % grid size in x
dy = Ly_T/Ny; % grid size in y
dz = Lz_T/Nz; % grid size in z
x = x_min_T + (0:(Nx-1))*dx;
y = y_min_T + (0:(Ny-1))*dy;
z = z_min_T + (0:(Nz-1))*dz;
[X,Y,Z] = meshgrid(x,y,z);
m = delta/dx;% m value

% Mask functions:
% Construct Mask function (chi) to distinguish the ficititious nodes
chi = ones (Nx, Ny, Nz);
chi (X <x_min | X > x_max) = 0;
chi (Y <y_min | Y > y_max) = 0;
chi (Z <z_min | Z > z_max) = 0;
% create the geometry of the big N
chi_N = ones(Nx,Ny,Nz);
chi_N(X<-65e-6 & (Y<35e-6 & Y>-35e-6)) = 0;
chi_N(X>65e-6 & (Y<35e-6 & Y>-35e-6)) = 0;
chi_N((X<15e-6 & X>-25e-6) & Y<-7/4*X-33.75e-6) = 0;
chi_N((X<25e-6 & X>-15e-6) & Y>-7/4*X+33.75e-6) = 0;
chi_N((X<-15e-6 & X>-25e-6) & (Y<-35e-6 & Y>-60e-6)) = 1;
chi_N((X<25e-6 & X>15e-6) & (Y>35e-6 & Y<60e-6)) = 1;
chi_N(X>75e-6 | X<-75e-6) = 0;
chi_N(Y>60e-6 | Y<-60e-6) = 0;
chi_N(Z>20e-6 | Z<-20e-6) = 0;
