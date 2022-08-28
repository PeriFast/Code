%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  ________ __________________ _________________________ ________________ %
%  ___  __ \___  ____/___  __ \____  _/___  ____/___    |__  ___/___  __/ %
%  __  /_/ /__  __/   __  /_/ / __  /  __  /_    __  /| |_____ \ __  /    %
%  _  ____/ _  /___   _  _, _/ __/ /   _  __/    _  ___ |____/ / _  /     %
%  /_/      /_____/   /_/ |_|  /___/   /_/       /_/  |_|/____/  /_/      %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code solves a 3D peridynamic corrosion problem with multi pits
% growth
% via boundary-adapted spectral method with Embedded Constraint(BASM-EC)
% by: Longzhen Wang, Dr. Siavash Jafarzadeh, Dr. Florin Bobaru
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
% Physical inputs for pitting corrosion problems
inputs;
nodes_and_sets;
Initial_conditions;
Kernel_functions;
Boundary_conditions;
% %output to tecplot file
if (is_output_to_Tecplot == 1)
    tdata=[];
    tdata.Nvar=4;
    tdata.varnames={'x','y','z','L'};
    tdata.cubes(1).zonename='mysurface zone';
    %totally nodes [3x2x2]
    tdata.cubes(1).x=X;
    tdata.cubes(1).y=Y;
    tdata.cubes(1).z=Z;
    tdata.cubes(1).v(1,:,:,:)=chi_l;
    tec_tmp = 1;
end
%generate output movie
if (is_plot_in_Matlab == 1)
    writerObj=VideoWriter('bigN_pit.avVi');
    open(writerObj);
end
% Time integration (Forward Euler):
time_step = 1;% time step counter
ks = 1;% snapshot counter
Output = struct;% struct variable to record output data

for t = dt:dt:t_max 
    fprintf('time step: %d\n',time_step);
    % update the volume constraints
    update_VC;
    % update the concentration C
    C = chi.*(C+ + dt*((chi_l).*ifftn(convolveInFourier_diff(fftn(C.*(chi_l)))) -...
    ((chi_l).*C).*ifftn(convolveInFourier_diff(fftn(chi_l))) + ...
    (chi_l_pit-chi_salt).*ifftn(convolveInFourier_corr(fftn(chi_s))) -...
    chi_s.*ifftn(convolveInFourier_corr(fftn(chi_l_pit-chi_salt)))))+ (1 - chi).*w;

    % Update mask functions for liquid domain, salt layer, and liquid domain:
    chi_l (C < C_sat) = 1; %find liquid node
    chi_l_pit(chi_l==1 & chi_N==1) = 1;
    chi_salt = zeros(Nx,Ny,Nz);
    chi_salt(C >= C_sat & chi_l_pit==1) = 1;
    chi_s = 1 - chi_l;
    
    % Dump output (snapshots)
    if (abs(t-t_target) <= dt)
        % Dump data in the struct variable: Output
        fprintf('...dumping output at %d\n', t);
        Output = dump_output(Output,ks,C,chi_l);
        % Visualization (snapshots)
        if (is_plot_in_Matlab == 1)
            fprintf('...plotting...\n');
            visualization;
        end
        if (is_output_to_Tecplot == 1)
            % output data to tecplot as well
            fprintf('...dumping output to Tecplot...\n');
            tec_tmp = tec_tmp + 1;
            tdata.cubes(tec_tmp).x=X;
            tdata.cubes(tec_tmp).y=Y;
            tdata.cubes(tec_tmp).z=Z;
            tdata.cubes(tec_tmp).v(1,:,:,:)=chi_l;
        end
        t_target = t_target + t_output;
        ks = ks + 1;
    end
    time_step = time_step + 1;
end
% computation is finished, save the results
if (is_plot_in_Matlab)
    close(writerObj);
end
if (is_output_to_Tecplot)
    mat2tecplot(tdata,'UNL_N_pitting_corrosion.plt')
end
fprintf('...saving results to file...\n');
save('Results.mat','Output','X','Y','Z','t','C','-v7.3')