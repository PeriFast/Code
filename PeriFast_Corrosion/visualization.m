function visualization (X,Y,Z,C,Ldx,dx,Ldy,dy,Ldz,dz,t,C_sat,writerObj)
% at every second
% plot the result, create a 2D slice normal to z direction
% output the concentration data to tecplot
% the user could add any other plots freely
xs = [];
ys = [];
zs = 0;
slice(X,Y,Z,C,xs,ys,zs);
shading flat
xlabel('X')
ylabel('Y')
zlabel('Z')
xlim([-Ldx/2+dx,Ldx/2-dx])
ylim([-Ldy/2+dy,Ldy/2-dy])
zlim([-Ldz/2+dz,Ldz/2-dz])
title ( sprintf ('t =% 1.4f',t));
colorbar
caxis([0 C_sat])
view(2)
drawnow
% take frame for movie generate
frame = getframe(gcf);
writeVideo(writerObj,frame);
end