%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This module takes the outputs from dump_output.m, the snapshot number,
% nodal coordinates, and the body node set, and uses them to visualize the
% results 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% for plotting outputs

chiB_lambda = chiB.*(Output(ks).lambda); % mask nodes outside the body or damaged nodes
plot_nodes = logical(chiB_lambda);% nodes that belong to the main body
x_plot = X(plot_nodes); %  coorniates of nodes in x-direction
y_plot = Y(plot_nodes); %  coorniates of nodes in y-direction
z_plot = Z(plot_nodes); %  coorniates of nodes in z-direction

u1_plot = Output(ks).u1(plot_nodes);  % displacement in x- direction 
u2_plot = Output(ks).u2(plot_nodes);  % displacement in y- direction
u3_plot = Output(ks).u3(plot_nodes);  % displacement in z- direction

% nodal coordinates in current configurartion
xcur_plot = x_plot + u1_plot;
ycur_plot = y_plot + u2_plot;
zcur_plot = z_plot + u3_plot;

% output selection for plots
% visualization_var.output1;
% num_of_outputs = visualization_var.No;
num_of_outputs= size(outputs_var_for_visualization,2);

for i = 1:num_of_outputs
figure(i);

outFilename = sprintf('output%d', i);

out_var = outputs_var_for_visualization(1,i);
if out_var  == 1
    output_plot = Output(ks).u1(plot_nodes);
    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('u1 ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 2
    output_plot = Output(ks).u2(plot_nodes);
    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('u2 ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 3
    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    output_plot = Output(ks).u3(plot_nodes);
    title ( sprintf ('u3 ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 4
    output_plot = Output(ks).u_mag(plot_nodes);
    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('u_mag ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 5
    output_plot = Output(ks).v1(plot_nodes);
    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    caxis([-1 1]);
    title ( sprintf ('v1 ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 6
    output_plot = Output(ks).v2(plot_nodes);
        scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    caxis([-3.5 3.5])
    title ( sprintf ('v2 ,t = %1.2e sec',dt*ks*snap));
    
end
if out_var  == 7
    output_plot = Output(ks).v3(plot_nodes);
        scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('v3 ,t = %1.2e sec',dt*ks*snap));
end

if out_var  == 8
    output_plot = Output(ks).v_mag(plot_nodes);
        scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('v_mag ,t = %1.2e sec',dt*ks*snap));
end
if out_var  == 9
    output_plot = Output(ks).W(plot_nodes);    scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
        caxis([0 1500])
    title ( sprintf ('W ,t = %1.2e sec',dt*ks*snap));

end
if out_var  == 10
    output_plot = Output(ks).d(plot_nodes);
        scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    caxis([0 1]);
    title ( sprintf ('damage ,t = %1.2e sec',dt*ks*snap));
    
end
if out_var  == 11
    output_plot = Output(ks).lambda(plot_nodes);
        scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,output_plot(:));
    colormap jet
    axis equal;
    title ( sprintf ('lambda ,t = %1.2e sec',dt*ks*snap));
end
colorbar;
drawnow
end

% create movies from the frams (snapshots)
create_Matlab_video;

