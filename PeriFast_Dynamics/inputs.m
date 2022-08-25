% create input file
function [props, t_max, dt, snap, Fb, IC_u, IC_v, trac_x, trac_y, trac_z,...
    dispBC_x, dispBC_y, dispBC_z, plot_output] = inputs
% Physical inputs:

props = [0; 2440; 3.8; 72e9; 0.25]; % material properties
% props (1): mat_type (0:BB, 1: Linearized SB, 2: correspondence SB)
% props (2): rho(density) 
% props (3): G0 (fracture energy release rate)
% props (4): E (Young's modulus)
% props (5): nu (Poisson ratio if not bond-based)

t_max = 33e-6; % maximum time
dt = 5e-8; % time step
snap = 5; % number of steps between snapshots(dumping output data)

% visualization parameter
plot_output = 1 ; % plot output during analysis:1,  Do not plot:0

%%% Body force density functions:
Fb(1).func = @(x,y,z,t)0;
Fb(2).func = @(x,y,z,t)0;
Fb(3).func = @(x,y,z,t)0;

%%% Initial condition functions:
IC_u(1).func = @(x,y,z)0;
IC_u(2).func = @(x,y,z)0;
IC_u(3).func = @(x,y,z)0;
IC_v(1).func = @(x,y,z)0;
IC_v(2).func = @(x,y,z)0;
IC_v(3).func = @(x,y,z)0;


%%% Boundary Conditions

% tractions:
% in x
trac_x.No = 0;% number of tractions in x
% in y
trac_y.No = 2;% number of tractions in y
trac_y(1).func = @(x,y,z,t) 4e6;% value (can be space/time dependent)
trac_y(2).func = @(x,y,z,t) -4e6; % 
% in z
trac_z.No = 0;% number of tractions in z

% displacements 
% in x
dispBC_x.No = 0;% number of tractions in x
% in y
dispBC_y.No = 0;% number of tractions in y
% in z
dispBC_z.No = 0;% number of tractions in z

end