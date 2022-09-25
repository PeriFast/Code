%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ________ __________________ _________________________ ________________ %
%  ___  __ \___  ____/___  __ \____  _/___  ____/___    |__  ___/___  __/ %
%  __  /_/ /__  __/   __  /_/ / __  /  __  /_    __  /| |_____ \ __  /    %
%  _  ____/ _  /___   _  _, _/ __/ /   _  __/    _  ___ |____/ / _  /     %
%  /_/      /_____/   /_/ |_|  /___/   /_/       /_/  |_|/____/  /_/      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code solves 3D defromation and fracture problems with peridynamic(uniform)
% models discretized using the Fast Convolution-Based Method (FCBM)
% Detailed description of the code can be found in:
% 'PeriFast/Dynamics: a MATLAB code for explicit fast convolution-based
% peridynamic analysis of deformation and fracture'
% By: Siavash Jafarzadeh, Farzaneh Mousavi and Florin Bobaru
%see https://doi.org/10.21203/rs.3.rs-2019917/v1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
% (For multithreaded computation, uncomment the command below, and give the
%  maximum number of computational threads you want to use in parentheses):
LASTN = maxNumCompThreads(1);

% Get inputs
 inputs;

% Get nodes and sets
 [delta,Box_T,Nx,Ny,Nz,X,Y,Z,dv,chiB,chit_x,chit_y,chit_z,chiG_x,chiG_y,...
    chiG_z,chi_predam,chiOx,chiOy,chiOz,dy] = nodes_and_sets(props,dt);

% Construct constitutive invariants
 constit_invar = pre_constitutive(props,delta,X,Y,Z,Box_T);

% Assign initial conditions
u1_0 = IC_u(1).func(X,Y,Z);
u2_0 = IC_u(2).func(X,Y,Z);
u3_0 = IC_u(3).func(X,Y,Z);
v1_0 = IC_v(1).func(X,Y,Z);
v2_0 = IC_v(2).func(X,Y,Z);
v3_0 = IC_v(3).func(X,Y,Z);

% Assign lambda0 (pre-damage)
lambda0 = 1 - chi_predam;
history_var.lambda = lambda0;

% Compute initial internal forces, tractions, and body forces at t=0
u1 = u1_0; u2 = u2_0; u3 = u3_0;
v1 = v1_0; v2 = v2_0; v3 = v3_0;
t = 0;  history_var.t = t;
update_tractions;
Fbx = Fb(1).func(X,Y,Z,t);
Fby = Fb(2).func(X,Y,Z,t);
Fbz = Fb(3).func(X,Y,Z,t);
[L1, L2, L3, W, history_var] = constitutive(props,u1,u2,u3,history_var,delta,...
    constit_invar,chiB,dv, Nx,Ny,Nz, run_in_gpu);
rho = props(2);

k = 1;% time step counter
total_time_step = round(t_max/dt);
snap = round(total_time_step/number_of_data_dump); % number of steps between snapshots for dumping output data
snap_frame = round(total_time_step/number_of_visualization_frames);
ks = 1;% snapshot counter
Output = struct;% struct varibale to record output data

%generate output movie
if (visualization_during_analysis == 1)
open_Matlab_video;
end
if (run_in_gpu==1)
    initial_gpu_arrays;
end
% open tecplot file if user chooses to save output as .plt file 
if (tecplot_output == 1)
   fileID1 = fopen('Results.plt','a'); 
   fprintf(fileID1,'%6s %6s %6s %12s\r\n','x','y','z','damage');
end

tic
for t = dt:dt:t_max % t is the current time    

    history_var.t = t;
   
    % Compute volume constraints
     update_VC;

    % Update u(x,y,z,t)
    u1 = chiOx.*(u1 + dt*(v1 + (dt/2/rho)*(L1 + btx + Fbx))) + wx;
    u2 = chiOy.*(u2 + dt*(v2 + (dt/2/rho)*(L2 + bty + Fby))) + wy;
    u3 = chiOz.*(u3 + dt*(v3 + (dt/2/rho)*(L3 + btz + Fbz))) + wz;
    
    % Store old values for velocity-verlet before updating
    L1_old = L1; btx_old = btx; Fbx_old = Fbx;
    L2_old = L2; bty_old = bty; Fby_old = Fby;
    L3_old = L3; btz_old = btz; Fbz_old = Fbz;
    
    % Update internal forces, damage, body forces, and BC

    [L1, L2, L3, W, history_var] = constitutive(props,u1,u2,u3,history_var,delta,...
        constit_invar,chiB,dv, Nx,Ny,Nz, run_in_gpu);
 
    update_tractions;
    
    Fbx = Fb(1).func(X,Y,Z,t);
    Fby = Fb(2).func(X,Y,Z,t);
    Fbz = Fb(3).func(X,Y,Z,t);
    
    % update velocity
    v1 = chiOx.*(v1 + (dt/2/rho)*((L1_old + btx_old + Fbx_old)+...
        (L1 + btx + Fbx)));
    v2 = chiOy.*(v2 + (dt/2/rho)*((L2_old + bty_old + Fby_old)+...
        (L2 + bty + Fby)));
    v3 = chiOz.*(v3 + (dt/2/rho)*((L3_old + btz_old + Fbz_old)+...
        (L3 + btz + Fbz)));
    
    % Dump output (snapshots)
    if (mod(round(t/dt),snap) == 0 || t == t_max)
      fprintf('time step: %d out of %i\n',k,total_time_step);

        % Dump data in the struct variable: Output
        fprintf('...dumping output...\n');
         dump_output;
        % Visualization (snapshots)
        if (visualization_during_analysis == 1 && (mod(round(t/dt), round(snap_frame/snap))==0 || t == t_max))
            fprintf('...plotting...\n');
            visualization;
        end

        ks = ks + 1;
    end
    
    k = k + 1;

end
toc
fprintf('***** ANALYSIS COMPLETED *****\n');

% close the video in the case it creates movie from the snapshots during
% analysis
if ( visualization_during_analysis == 1)
close_Matlab_video
end

% close tecplot file if it creates tecplot file
if (tecplot_output == 1)
   fclose(fileID1); 
end

% save outputs to Results.mat file:
fprintf('...saving results to file...\n');
save('Results.mat','Output','X','Y','Z','t','chiB','outputs_var_for_visualization',...
    'snap_frame','snap','dt','-v7.3')



