%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this module contains certain input data including material properties, 
% simulation time, time steps, initial and boundary conditions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Physical inputs:
props = [0; 2440; 3.8; 72e9; 0.25]; % material properties
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

number_of_data_dump = 100; %  %  number of data dumps
number_of_visualization_frames = 30; % number of frames for visualization,this number should be less than number of data dump

run_in_gpu = 0; % run in gpu:1, do not run in gpu:0;

% output parameters
 
tecplot_output = 0 ; % provide tecplot file :1,  Do not provide tecplot file:0

% visualization parameter
visualization_during_analysis = 0 ; % Matlab plot/animate output during analysis:1,  Do not plot/animate:0
% user can choose outputs for vizualization
outputs_var_for_visualization = [10]; % want to visualize  d from outputs
%the outputs defined in this version is:
% 1:  u1, 2: u2, 3: u3, 4: u_mag
% 5: v1, 6: v2, 7: v3, 8: v_mag
% 9: W, 10: d, 11: lambda
% user can add extra output for visualization by first defining in
% dump_output.m and modify the visualization.m,open_Matlab_video.m, create_Matlab_video.m and close_Matlab_video.m 


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
