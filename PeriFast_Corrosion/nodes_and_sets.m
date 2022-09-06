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
Nx = 2^7; % resolution in x (Best for FFT to use a power of 2)
Ny = 2^7; % resolution in y
Nz = 2^6; % resolution in z
dx = Lx_T/Nx; % grid size in x
dy = Ly_T/Ny; % grid size in y
dz = Lz_T/Nz; % grid size in z
x = x_min_T + (0:(Nx-1))*dx;
y = y_min_T + (0:(Ny-1))*dy;
z = z_min_T + (0:(Nz-1))*dz;
[X,Y,Z] = meshgrid(x,y,z);
m = [delta/dx, delta/dy, delta/dz];% m value along x, y, z directions
discretization_check(delta,Ldx,Ldy,Ldz,extension,Nx,Ny,Nz,m);
% Mask functions:
% Construct Mask function (chi) to distinguish the ficititious nodes
chi = ones (Nx, Ny, Nz);
chi (X <x_min | X > x_max) = 0;
chi (Y <y_min | Y > y_max) = 0;
chi (Z <z_min | Z > z_max) = 0;
% create the geometry of the big N, the dimensions can be found in 
%'PeriFast/Corrosion: a 3D pseudo-spectral peridynamic code for corrosion'
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

function discretization_check(delta,Ldx,Ldy,Ldz,extension,Nx,Ny,Nz,m)
%check horizon size
if(delta<=0)
    error('Delta must be a positive number');
end
if(Ldx<=0)
    error('Physical domain length along x has to be positive');
end
if(Ldy<=0)
    error('Physical domain length along y has to be positive');
end
if(Ldz<=0)
    error('Physical domain length along z has to be positive');
end
if(delta >= Ldx)
    warning('delta is larger than physical domain length along x, choose a smaller horizon');
end
if(delta >= Ldy)
    warning('delta is larger than physical domain length along y, choose a smaller horizon');
end
if(delta >= Ldz)
    warning('delta is larger than physical domain length along z, choose a smaller horizon');
end
if(extension < delta)
    error('To apply fictitious node method, the extension has to be at least delta');
end
if(Nx<=0)
    error('Resolution in x has to be positive');
end
if(Ny<=0)
    error('Resolution in y has to be positive');
end
if(Nz<=0)
    error('Resolution in z has to be positive');
end
if(m(1)< 3)
    warning('delta is less than three times discretization,finer discretization along x is recommended');
end
if(m(2)< 3)
    warning('delta is less than three times discretization,finer discretization along y is recommended');
end
if(m(3)< 3)
    warning('delta is less than three times discretization,finer discretization along z is recommended');
end
end

