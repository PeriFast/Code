% Physical inputs for pitting corrosion problems
corrosion_type = 1; % 0 represents uniform corrosion and 1 represents pitting corrosion
K = 860e-12; % diffusion coefficient of ion in the solution, unit in m^2/s
cur_i = 5.1e3; % initial corrosion current density, unit in A/m^2
n = 2.19;% average charge number of SS 304, no unit
F = 96485.33; % Faraday's constant, unit in C/mol
q = cur_i/(n*F); % dissolution flux

C_sat = 4600; % saturation concentration, unit in mol/m^3
C_solid = 142900; % solid concentration, unit in mol/m^3
t_max = 80; % corrosion duration time, unit in s
dt = 1e-3; % time step (should satisfy the stability condition)

%visualiztion parameters
is_plot_in_Matlab = 0; % if want to plot at certain time and generate a video
is_output_to_Tecplot = 0; % if want to write data to Tecplot at certain time
t_output = 0.1; %time interval of write data to Tecplot .plt file
t_target = t_output;