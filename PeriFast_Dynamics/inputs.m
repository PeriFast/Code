%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this module contains certain input data including material properties, 
% simulation time, time steps, initial and boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Physical inputs:
props = [2; 2440; 3.8; 72e9; 0.25]; % material properties
% props (1): mat_type (0:BB, 1: Linearized SB, 2: correspondence SB)
% props (2): rho(density) , unit in kg/m^3
% props (3): G0 (fracture energy release rate), unit in J/m^2
% props (4): E (Young's modulus), unit in  Pa
% props (5): nu (Poisson ratio if not bond-based)

t_max = 33e-6; % maximum time, unit in s
% safty check for t_max
if(t_max <= 0)
    error('t_max must be a positive number');
end
dt = 5e-8; % time step (should satisfy the stability condition), unit in s
%safty check for dt
if(dt > t_max)
    error('dt can not large than the total time');
end

run_in_gpu = 0; % run in gpu:1, do not run in gpu:0;

% output parameters
snap = 5; % number of steps between snapshots(dumping output data)
tecplot_output = 0 ; % provide tecplot file :1,  Do not provide tecplot file:0

% visualization parameter
visualization_during_analysis = 1 ; % Matlab plot/animate output during analysis:1,  Do not plot/animate:0

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
