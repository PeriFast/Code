% at every second
% plot the result, create a 2D slice normal to z direction
% output the concentration data to tecplot
% the user could add any other plots freely
xs = [];
ys = [];
zs = 19e-6;
slice(X,Y,Z,C,xs,ys,zs);
shading flat
%colormap jet
xlabel('X')
ylabel('Y')
zlabel('Z')
xlim([-Ldx/2+dx,Ldx/2-dx])
ylim([-Ldy/2+dy,Ldy/2-dy])
zlim([-Ldz/2+dz,Ldz/2-dz])
title ( sprintf ('t =% 1.4f',t));
colorbar
caxis([0 C_solid])
view(2)
drawnow
% take frame for movie generate
frame = getframe(gcf);
writeVideo(writerObj,frame);