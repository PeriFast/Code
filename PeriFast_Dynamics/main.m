%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ________ __________________ _________________________ ________________ %
%  ___  __ \___  ____/___  __ \____  _/___  ____/___    |__  ___/___  __/ %
%  __  /_/ /__  __/   __  /_/ / __  /  __  /_    __  /| |_____ \ __  /    %
%  _  ____/ _  /___   _  _, _/ __/ /   _  __/    _  ___ |____/ / _  /     %
%  /_/      /_____/   /_/ |_|  /___/   /_/       /_/  |_|/____/  /_/      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear; clc;
% (For multithreaded computation, uncomment the command below, and give the
%  maximum number of computational threads you want to use in parentheses):
LASTN = maxNumCompThreads(8);

% Get inputs
[props, t_max, dt, snap, Fb, IC_u, IC_v, trac_x, trac_y, trac_z,...
    dispBC_x, dispBC_y, dispBC_z, plot_output] = inputs;

% Get nodes and sets
[delta,Box_T,Nx,Ny,Nz,X,Y,Z,dv,chiB,chit_x,chit_y,chit_z,chiG_x,chiG_y,...
    chiG_z,chi_predam,chiOx,chiOy,chiOz,dy] = nodes_and_sets;

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
[btx,bty,btz] = update_tractions(trac_x,trac_y,trac_z,chit_x,chit_y,...
    chit_z,delta,Nx,Ny,Nz,X,Y,Z,t,dy);
Fbx = Fb(1).func(X,Y,Z,t);
Fby = Fb(2).func(X,Y,Z,t);
Fbz = Fb(3).func(X,Y,Z,t);
[L1, L2, L3, W, history_var] = constitutive(props,u1,u2,u3,history_var,delta,...
    constit_invar,chiB,dv, Nx,Ny,Nz);
rho = props(2);

k = 1;% time step counter
ks = 1;% snapshot counter
Output = struct;% struct varibale to record output data

for t = dt:dt:t_max % t is the current time
    
    fprintf('time step: %d\n',k);
    % Compute volume constraints
    [wx,wy,wz] = update_VC(dispBC_x,dispBC_y,dispBC_z,...
        chiG_x,chiG_y,chiG_z,Nx,Ny,Nz,X,Y,Z,t);
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
        constit_invar,chiB,dv, Nx,Ny,Nz);
 
    [btx,bty,btz] = update_tractions(trac_x,trac_y,trac_z,chit_x,chit_y,...
        chit_z,delta,Nx,Ny,Nz,X,Y,Z,t,dy);
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
    if (mod(t/dt,snap) < 1e-6)
        % Dump data in the struct variable: Output
        fprintf('...dumping output...\n');
        Output = dump_output(Output,ks,u1,u2,u3,v1,v2,v3,W,history_var);
        % Visualization (snapshots)
        if (plot_output == 1)
            fprintf('...plotting...\n');
            visualization(Output,ks,X,Y,Z,chiB,t);
        end
        ks = ks + 1;
    end
    
    k = k + 1;
    
end

fprintf('***** ANALYSIS COMPLETED *****\n');
% save outputs to Results.mat file:
fprintf('...saving results to file...\n');
save('Results.mat','Output','X','Y','Z','t','chiB','-v7.3')




