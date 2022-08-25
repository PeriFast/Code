function visualization(Output,ks,X,Y,Z,chiB,t) 

chiB_lambda = chiB.*(Output(ks).lambda);
plot_nodes = logical(chiB_lambda);% nodes that belong to the main body
x_plot = X(plot_nodes);
y_plot = Y(plot_nodes);
z_plot = Z(plot_nodes);

% output selection for plots
u1_plot = Output(ks).u1(plot_nodes);
u2_plot = Output(ks).u2(plot_nodes);
u3_plot = Output(ks).u3(plot_nodes);
v1_plot = Output(ks).v1(plot_nodes);
v2_plot = Output(ks).v2(plot_nodes);
v3_plot = Output(ks).v3(plot_nodes);
damage_plot = Output(ks).d(plot_nodes);
energy_plot = Output(ks).W(plot_nodes);

% nodal coordinates in current configurartion
xcur_plot = x_plot + u1_plot;
ycur_plot = y_plot + u2_plot;
zcur_plot = z_plot + u3_plot;

figure(1)
scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,damage_plot(:));
colormap jet
axis equal;
caxis([0 1])
title ( sprintf ('d , t = %1.2e sec',t));
colorbar;
drawnow

%%% user can uncomment the part below to plot other outputs:

% figure(2)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,v1_plot(:));
% colormap jet
% axis equal;
% caxis([-1 1])
% title ( sprintf ('v1 , t = %1.2e sec',t));
% colorbar;
% drawnow
% 
% figure(3)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,v2_plot(:));
% colormap jet
% axis equal;
% caxis([-3.5 3.5])
% title ( sprintf ('v2 , t = %1.2e sec',t));
% colorbar;
% drawnow
% 
% figure(4)
% scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5,energy_plot(:));
% colormap jet
% axis equal;
% caxis([0 1500])
% title ( sprintf ('W , t = %1.2e sec',t));
% colorbar;
% drawnow
     
end
