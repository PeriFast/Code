function visualization (X,Y,Z,C,Ldx,dx,Ldy,dy,Ldz,dz,t,C_sat,run_in_gpu,writerObj)
% at every second
% plot the result, create a 2D slice normal to z direction
% output the concentration data to tecplot
% the user could add any other plots freely
xs = [];
ys = [];
zs = 0;%19e-6;
if(run_in_gpu == 1)
    C=gather(C);
    X=gather(X);
    Y=gather(Y);
    Z=gather(Z);
    slice(X,Y,Z,C,xs,ys,zs);
else
    slice(X,Y,Z,C,xs,ys,zs);
end
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
caxis([0 C_sat])
view(2)
drawnow
% take frame for movie generate
frame = getframe(gcf);
writeVideo(writerObj,frame);
end