% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function contains the PD horizon and discrete geometrical data 
% including nodal coordinates and  characteristic functions that define
% various subdomains: the original body,constrained volumes,
% pre-damaged regions, and subregions where tractions applied as body forces 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [delta,Box_T,Nx,Ny,Nz,X,Y,Z,dv,chiB,chit_x,chit_y,chit_z,...
    chiG_x,chiG_y,chiG_z,chi_predam,chiOx,chiOy,chiOz,dy]...
    = nodes_and_sets


delta = 1.02e-3;  % horizon size

% define enclosing box
x_min = 0; x_max = 0.1;
y_min = 0; y_max = 0.04;
z_min = 0; z_max = 0.002;

Ldx = x_max - x_min; % fitted_box - x dimension
Ldy = y_max - y_min; % fitted_box - y dimension
Ldz = z_max - z_min; % fitted_box - z dimension



% define number of nodes in each direction
% Nx = 510; % resolution in x (Best for FFT to use a power of 2)
% Ny = 210;  % resolution in y
% Nz = 20;  % resolution in z
Nx = 256; % resolution in x (Best for FFT to use a power of 2)
Ny = 106;  % resolution in y
Nz = 10;  % resolution in z

% Extend the fitted box to the periodic domain (T) by (m+1)dx on both sides
extension = 2e-3;

x_min_T = x_min;
x_max_T = x_max + extension;
y_min_T = y_min;
y_max_T = y_max + extension;
z_min_T = z_min;
z_max_T = z_max + extension;

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

Box_T.dx =  dx; Box_T.dy =  dy; Box_T.dz =  dz;
x = (x_min_T + (0:Nx - 1)*dx)';
y = (y_min_T + (0:Ny - 1)*dy)';
z = (z_min_T + (0:Nz - 1)*dz)';
[X,Y,Z] = meshgrid(x,y,z);
dv = dx*dy*dz;

% check discritization
discretization_check(delta,Nx,Ny,Nz,dx,dy,dz,Ldx,Ldy,Ldz,extension);

% Construct Mask functions (ChiB): defines the body configuration
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
% in y
chiG_y.No = 0;% number of tractions in y
% in z
chiG_z.No = 0;% number of tractions in z

% pre-damage set :
chi_predam = double(chiB == 1 & abs(Y - y_min - Ldy/2)<= (delta/2) &...
    X < x_min + Ldx/2);

% assemble chi_gamma for boundaries
chiGx = assemble_chi(chiG_x,Nx,Ny,Nz);
chiGy = assemble_chi(chiG_y,Nx,Ny,Nz);
chiGz = assemble_chi(chiG_z,Nx,Ny,Nz);
chiOx = chiB - chiGx;
chiOy = chiB - chiGy; 
chiOz = chiB - chiGz; 

end

% function to assemble chi_gamma for volume contraints pretaining to each
% coordinate direction
function chi_total = assemble_chi (chi,Nx,Ny,Nz)
chi_total = zeros(Ny,Nx,Nz);
n = chi.No;
for i = 1: n(1)
    chi_total = chi_total + chi(i).set;
end
end

function discretization_check(delta,Nx, Ny,Nz,dx,dy,dz,Ldx,Ldy,Ldz,extension)
% safty check fo horizon size
if(delta <= 0)
    error('delta must be a positive number');
end

% safty check for extension
if(extension <= delta)
    error('extension must be at least equal to delta');
end
% safty check for physical domain size
if(delta >= Ldx)
    warning('delta is larger than physical domain length in x direction, choose a smaller horizon');
end
% safty check for number of nodes (need to be an even number in curent
% version of code)
if(mod(Nx,2)== 1 || mod(Ny,2)== 1 ||mod(Nz,2)==1)
    error('number of nodes are not even, try even numbers for Nx, Ny and Nz');
end
if(delta >= Ldy)
    warning('delta is larger than physical domain length in y direction, choose a smaller horizon');
end
if(delta >= Ldz)
    warning('delta is larger than physical domain length in z direction, choose a smaller horizon');
end
% safty check for m-value factor
if(delta/dx < 3 || delta/dy < 3  || delta/dz < 3)
    warning('m-value is less than 3, make discritization finer');
end
if(delta/dx - floor(delta/dx) < 1e-6 || delta/dy - floor(delta/dy) < 1e-6  || delta/dz - floor(delta/dz) < 1e-6)
    error('m-value is integer, multiply delta by 1.02');
end
end
