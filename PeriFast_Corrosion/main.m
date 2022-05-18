%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code solves a 3D peridynamic corrosion problem with multi pits
% growth
% via boundary-adapted spectral method with Embedded Constraint(BASM-EC)
% by: Longzhen Wang
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear; clc; close all;
% Physical inputs for pitting corrosion problems
Pit_corrosion_parameters_input;
Physical_domain_discretization;
Initial_conditions;
Kernel_functions;
Boundary_conditions;
Create_files_for_output;
% Time integration (Forward Euler):
% t is the current time
for t = dt:dt:t_max 
    Update_C;
    Update_characteristic_functions;
    Update_volume_constraints;
    Plot_and_Output_data;
end
Finalize_and_Save;