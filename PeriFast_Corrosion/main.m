%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ________ __________________ _________________________ ________________ %
%  ___  __ \___  ____/___  __ \____  _/___  ____/___    |__  ___/___  __/ %
%  __  /_/ /__  __/   __  /_/ / __  /  __  /_    __  /| |_____ \ __  /    %
%  _  ____/ _  /___   _  _, _/ __/ /   _  __/    _  ___ |____/ / _  /     %
%  /_/      /_____/   /_/ |_|  /___/   /_/       /_/  |_|/____/  /_/      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code solves 3D corrosion problems (uniform
% corrosion and pitting corrosion with multiple growing/merging pits) with peridynamic
% models discretized using the Fast Convolution-Based Method (FCBM)
% Detailed description of the code can be found in
% 'PeriFast/Corrosion: a 3D pseudo-spectral peridynamic code for corrosion'
% by: Longzhen Wang, Dr. Siavash Jafarzadeh, Dr. Florin Bobaru
% see https://doi.org/10.21203/rs.3.rs-2046856/v1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
inputs;
nodes_and_sets;
initial_conditions;
kernel_functions;
boundary_conditions;
% initialize output to tecplot file
if (is_output_to_Tecplot == 1)
    tdata=[];
    tdata.Nvar=4;
    tdata.varnames={'x','y','z','C'};
    tdata.cubes(1).x=X;
    tdata.cubes(1).y=Y;
    tdata.cubes(1).z=Z;
    tdata.cubes(1).v(1,:,:,:)=C;
    tec_step = 1;
end
%generate output movie
if (is_plot_in_Matlab == 1)
    writerObj=VideoWriter('bigN_corrosion');
    open(writerObj);
end
% Time integration (Forward Euler):
time_step = 1;% time step counter
ks = 1;% snapshot counter
total_time_step = round(t_max/dt);
Output = struct;% struct variable to record output data
if(run_in_gpu == 1)
    initial_gpu_arrays;
end
tic
for t = dt:dt:t_max 
    fprintf('time step: %d out of %i\n',time_step,total_time_step);
    % update the volume constraints
    C_w = update_VC(C_w,C,Nx,Ny,Nz,n1,n2,n3,n4,n5,n6,X,Y,Z,Lx_T,Ly_T,Lz_T,delta,BC_type,BC_value);
    % update the concentration C
    [C,chi_l,chi_s] = update_C(corrosion_type,dt,C,C_w,C_sat,chi_l,chi_N,chi,Nx,Ny,Nz,convolveInFourier_diff,convolveInFourier_corr,has_salt_layer);
    % Dump output (snapshots)
    if (abs(t-t_output_target) <= dt)
        % Dump data in the struct variable: Output
        fprintf('time step: %d out of %i\n',time_step,total_time_step);
        fprintf('...dumping output at %d\n', t);
        [Output,ks] = dump_output(Output,ks,C,chi_l,t,run_in_gpu);

        if (is_output_to_Tecplot == 1)
            % output data to tecplot
            fprintf('...dumping output to Tecplot...\n');
            tec_step = tec_step + 1;
            tdata = dump_output_Tecplot(tdata,X,Y,Z,C,run_in_gpu,tec_step);
        end
        t_output_target = t_output_target + t_output_interval;
        ks = ks + 1;
    end
    if(abs(t-t_plot_target) <= dt)
        % Visualization (snapshots)
        if (is_plot_in_Matlab == 1)
            fprintf('time step: %d out of %i\n',time_step,total_time_step);
            fprintf('...plotting...\n');
            visualization(X,Y,Z,C,Ldx,dx,Ldy,dy,Ldz,dz,t,C_sat,writerObj);
        end
        t_plot_target = t_plot_target + t_plot_interval;
    end
    time_step = time_step + 1;
end
toc
% computation is finished, save the results
if (is_plot_in_Matlab)
    close(writerObj);
end
if (is_output_to_Tecplot)
    mat2tecplot(tdata,'UNL_N_corrosion.plt');
end
fprintf('...saving results to file...\n');
save('Results.mat','Output','X','Y','Z','Ldx','Ldy','Ldz','dx','dy','dz','C_sat','t','chi_N','chi','-v7.3')
fprintf('...simulation done...\n');