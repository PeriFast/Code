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

% output selection for plots
u1_plot = Output(ks).u1(plot_nodes);  % displacement in x- direction 
u2_plot = Output(ks).u2(plot_nodes);  % displacement in y- direction
u3_plot = Output(ks).u3(plot_nodes);  % displacement in z- direction
v1_plot = Output(ks).v1(plot_nodes);  % velocity in x- direction
v2_plot = Output(ks).v2(plot_nodes);  % velocity in y- direction
v3_plot = Output(ks).v3(plot_nodes);  % velocity in z- direction
damage_plot = Output(ks).d(plot_nodes); % damage index
energy_plot = Output(ks).W(plot_nodes);  % strain energy density

% nodal coordinates in current configurartion
xcur_plot = x_plot + u1_plot;
ycur_plot = y_plot + u2_plot;
zcur_plot = z_plot + u3_plot;

% plot damage index as figure (1)
figure(1)
scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,damage_plot(:));
colormap jet
axis equal;
caxis([0 1])
title ( sprintf ('d ,t = %1.2e sec',dt*ks*5));
colorbar;
drawnow



%%% user can uncomment the part below to plot other outputs:

% plot v1 as figure (2), velocity in x direction
% figure(2)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,v1_plot(:));
% colormap jet
% axis equal;
% caxis([-1 1])
% title ( sprintf ('v1 , t = %1.2e sec',t));
% colorbar;
% drawnow
% 
% plot v2  as figure (3), velocity in ydirection
% figure(3)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,v2_plot(:));
% colormap jet
% axis equal;
% caxis([-3.5 3.5])
% title ( sprintf ('v2 , t = %1.2e sec',t));
% colorbar;
% drawnow
% 
% plot strain energy density  figure (4), 
% figure(4)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,energy_plot(:));
% colormap jet
% axis equal;
% caxis([0 1500])
% title ( sprintf ('W , t = %1.2e sec',t));
% colorbar;
% drawnow


% create movies from the frams (snapshots)
create_Matlab_video(damage_video);

