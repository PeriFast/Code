% Physical inputs for pitting corrosion problems
corrosion_type = 0; % 0 represents uniform corrosion and 1 represents pitting corrosion
K = 1297e-12; % diffusion coefficient of ion in the solution, unit in m^2/s
cur_i = 1.45e3; % initial corrosion current density, unit in A/m^2
n = 2;% average charge number of SS 304, no unit
F = 96485.33; % Faraday's constant, unit in C/mol
q = cur_i/(n*F); % dissolution flux

C_sat = 5000; % saturation concentration, unit in mol/m^3
C_solid = 141000; % solid concentration, unit in mol/m^3
t_max = 300; % corrosion duration time, unit in s
dt = 0.8e-3; % time step (should satisfy the stability condition)

%visualization parameters
is_plot_in_Matlab = 1; % if want to plot at certain time and generate a video, set to 1
is_output_to_Tecplot = 1; % if want to write data to Tecplot at certain time, set to 1
freq_output = 30;%data dump frequence
freq_plot = 100; %plot frequence
if(freq_output == 0)
    t_output_interval = nan;
else
    t_output_interval = t_max/freq_output; %time interval of write data
end
t_output_target = t_output_interval;
if(freq_plot == 0)
    t_plot_interval = nan;
else
    t_plot_interval = t_max/freq_plot; %time interval of plotting in MATLAB
end
t_plot_target = t_plot_interval;

has_salt_layer = 0; %if consider salt layer effect, set to 1

run_in_gpu = 0; %if want to run in gpu, set to 1

input_check(corrosion_type, K, cur_i, n, F, C_sat, C_solid, t_max, freq_output, freq_plot);

function input_check(corrosion_type, K, cur_i, n, F, C_sat, C_solid, t_max, freq_output, freq_plot)
if(corrosion_type ~= 0 && corrosion_type ~= 1)
    error('Corrosion_type is wrong');
end
if(K <= 0)
    error('Diffusion coefficient K must be a positive number');
end
if(cur_i <= 0)
    error('Current density cur_i must be a positive number');
end
if(n <= 0)
    error('Average charge number n must be a positive number');
end
if(F ~= 96485.33)
    error('Faraday constant is a fixed value, do not change it');
end
if(C_sat <= 0)
    error('Saturation concentration must be a positive number');
end
if(C_solid <= 0)
    error('Solid concentration must be a positive number');
end
if(t_max <= 0)
    error('Corrosion duration time must be a positive number');
end
if(freq_output <=0)
    warning('No data will be dumped. Set freq_output to a positive number');
end
if(freq_plot <=0)
    warning('No visualization will be plot. Set freq_plot to a positive number');
end
end