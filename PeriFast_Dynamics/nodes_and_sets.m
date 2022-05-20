% create mesh file
function [delta,Box_T,Nx,Ny,Nz,X,Y,Z,dv,chiB,chit_x,chit_y,chit_z,...
    chiG_x,chiG_y,chiG_z,chi_predam,chiOx,chiOy,chiOz,dy]...
    = nodes_and_sets


delta = 1.02e-3;

x_min = 0; x_max = 0.1;
y_min = 0; y_max = 0.04;
z_min = 0; z_max = 0.002;

% x_min = -0.05; x_max = 0.05;
% y_min = -0.02; y_max = 0.02;
% z_min = -0.001; z_max = 0.001;

Ldx = x_max - x_min; % fitted_box - x dimension
Ldy = y_max - y_min; % fitted_box - y dimension
Ldz = z_max - z_min; % fitted_box - z dimension

Nx = 510; % resolution in x (Best for FFT to use a power of 2)
Ny = 210;  % resolution in y
Nz = 20;  % resolution in z

% Nx = 306; % resolution in x (Best for FFT to use a power of 2)
% Ny = 126;  % resolution in y
% Nz = 12;  % resolution in z

% Extend the fitted box to the periodic domain (T) by (m+1)dx on both sides
extension = 2e-3;
x_min_T = x_min;
x_max_T = x_max + extension;
y_min_T = y_min;
y_max_T = y_max + extension;
z_min_T = z_min;
z_max_T = z_max + extension;

% extension = delta;
% x_min_T = x_min - extension;
% x_max_T = x_max + extension;
% y_min_T = y_min - extension;
% y_max_T = y_max + extension;
% z_min_T = z_min - extension;
% z_max_T = z_max + extension;

% Box T dimensions
Lx_T = x_max_T - x_min_T;
Ly_T = y_max_T - y_min_T;
Lz_T = z_max_T - z_min_T;

% store box info for adjusting kernel functions
Box_T.xmin = x_min_T; Box_T.xmax = x_max_T; Box_T.Lx = Lx_T;
Box_T.ymin = y_min_T; Box_T.ymax = y_max_T; Box_T.Ly = Ly_T;
Box_T.zmin = z_min_T; Box_T.zmax = z_max_T; Box_T.Lz = Lz_T;

% grid spacing
dx = Lx_T/Nx;
dy = Ly_T/Ny;
dz = Lz_T/Nz;
x = (x_min_T + (0:Nx - 1)*dx)';
y = (y_min_T + (0:Ny - 1)*dy)';
z = (z_min_T + (0:Nz - 1)*dz)';
[X,Y,Z] = meshgrid(x,y,z);
dv = dx*dy*dz;

% Construct Mask functions (ChiB ): defines the body configuration
% chiB = ones (Ny, Nx, Nz);
% chiB (Z < z_min | Z > z_max )  = 0;
% chiB (Y < y_min | Y > y_max ) = 0;
% chiB (X < x_min | X > x_max ) = 0;
chiB = double(X >= x_min & X <= x_max & Y >= y_min & Y <= y_max &...
    Z >= z_min & Z <= z_max);
% boundary layers mask function for applying tractions:chib
% in x
chit_x.No = 0;% number of tractions in x
% in y
chit_y.No = 2;% number of tractions in y
chit_y(1).set = double(chiB == 1 & Y > y_max - delta + dy/2 & Y < y_max + dy/2);
chit_y(2).set = double(chiB == 1 & Y > y_min - dy/2 & Y < y_min + delta - dy/2);


% in z
chit_z.No = 0;% number of tractions in z


% boundary layers mask function for applying displacements:chiG
% in x
chiG_x.No = 0;% number of tractions in x
% chiG_x(1).set = double(chiB == 1 & X > x_max - delta + dx/2 & X < x_max + dx/2);
% chiG_x(2).set = double(chiB == 1 & X > x_min - dx/2 & X < x_min + delta - dx/2);
% in y
chiG_y.No = 0;% number of tractions in y
% chiG_y(1).set = double(chiB == 1 & Y > y_max - delta + dy/2 & Y < y_max + dy/2);
% chiG_y(2).set = double(chiB == 1 & Y > y_min - dy/2 & Y < y_min + delta - dy/2);
% in z
chiG_z.No = 0;% number of tractions in z
% chiG_z(1).set = double(chiB == 1 & Z > z_max - delta + dz/2 & Z < z_max + dz/2);
% chiG_z(2).set = double(chiB == 1 & Z > z_min - dz/2 & Z < z_min + delta - dz/2);

% pre-damage set :
chi_predam = double(chiB == 1 & abs(Y - y_min - Ldy/2)<= (delta/2) &...
    X < x_min + Ldx/2);


% chi_predam=  ( X < 0 & abs(Y) <= delta/2 );
% assemble chi_gamma and chi_t for boundaries
chiGx = assemble_chi(chiG_x,Nx,Ny,Nz);
chiGy = assemble_chi(chiG_y,Nx,Ny,Nz);
chiGz = assemble_chi(chiG_z,Nx,Ny,Nz);
chiOx = chiB - chiGx;
chiOy = chiB - chiGy; 
chiOz = chiB - chiGz; 

end

function chi_total = assemble_chi (chi,Nx,Ny,Nz)
chi_total = zeros(Ny,Nx,Nz);
n = chi.No;
for i = 1: n(1)
    chi_total = chi_total + chi(i).set;
end
end


