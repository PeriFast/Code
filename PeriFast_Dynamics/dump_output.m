%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This module gets the snapshot number (ks), displacements and velocities 
% in x, y, and z directions, strain energy density, damage index, and lambda
% as inputs, and stores them in a single “structure”-type MATLAB 
% variable named Output. if tecplot_output ==1 in inputs.m, the selected 
% outputs are saved in tecplot file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user can add any desired quantity to the "Output" varibale
Output(ks).u1 = u1; % displacement in x-direction
Output(ks).u2 = u2; % displacement in y-direction
Output(ks).u3 = u3; % displacement in z-direction
Output(ks).u_mag = sqrt(u1.^2 + u2.^2 + u3.^2); % discplement magnitude
Output(ks).v1 = v1; % velocity in x-direction
Output(ks).v2 = v2; % velocity in y-direction
Output(ks).v3 = v3; % velocity in z-direction
Output(ks).v_mag = sqrt(v1.^2 + v2.^2 + v3.^2);  % velocity magnitude
Output(ks).W = W; % strain energy density
Output(ks).d = history_var.damage; % damage index
Output(ks).lambda = history_var.lambda;  % lambda



% if user wants to have output as tecplot file (tecplot_output ==1 in inputs.m)
% create techplot for damage results
if (tecplot_output == 1)
chiB_lambda = chiB.*(Output(ks).lambda); 
plot_nodes = logical(chiB_lambda);% nodes that belong to the main body  

% output selection for plots
u1_plot = Output(ks).u1(plot_nodes);  % displacement in x- direction 
u2_plot = Output(ks).u2(plot_nodes);  % displacement in y- direction
u3_plot = Output(ks).u3(plot_nodes);  % displacement in z- direction  
x_plot = X(plot_nodes); %  coorniates of nodes in x-direction
y_plot = Y(plot_nodes); %  coorniates of nodes in y-direction
z_plot = Z(plot_nodes); %  coorniates of nodes in z-direction

% nodal coordinates in current configurartion
xcur_plot = x_plot + u1_plot;
ycur_plot = y_plot + u2_plot;
zcur_plot = z_plot + u3_plot;
% create tecplot file for selected outputs
damage_plot = Output(ks).d(plot_nodes); % damage index
A=[xcur_plot(:)';ycur_plot(:)';zcur_plot(:)';damage_plot(:)'];
fprintf(fileID1, '%14s\r\r\n','ZONE F=POINT');
fprintf(fileID1,'%12.8f %12.8f %12.8f %12.8f\r\n',A);
end
