function visualization(Output,ks,X,Y,Z,chiB,t) 

chiB_lambda = chiB.*(Output(ks).lambda);
plot_nodes = logical(chiB_lambda);
x_plot = X(plot_nodes);
y_plot = Y(plot_nodes);
z_plot = Z(plot_nodes);
u1_plot = Output(ks).u1(plot_nodes);
u2_plot = Output(ks).u2(plot_nodes);
u3_plot = Output(ks).u3(plot_nodes);
xcur_plot = x_plot + u1_plot;
ycur_plot = y_plot + u2_plot;
zcur_plot = z_plot + u3_plot;
damage_plot = Output(ks).d(plot_nodes);
figure(1)
scatter3(xcur_plot(:),ycur_plot(:),zcur_plot(:), 5, damage_plot(:));
colormap jet
axis equal;
title ( sprintf ('damage  t = %1.2e sec',t));
 colorbar;
 drawnow
 
%  figure(2)
% scatter3(x_plot(:),y_plot(:),z_plot(:), 5, damage_plot(:));

% shading flat
% % axis equal;
% % xlim([-0.005,0.005])
% % ylim([-0.04,0.04])
% % zlim([-0.1,0.1])
%  view([90,0]);
% % axis([-0.0027 0.0027 -0.06 0.06 -0.025 0.025])
%  colorbar;
%  drawnow
        
end
