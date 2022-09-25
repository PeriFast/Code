function visualization (X,Y,Z,C,Ldx,dx,Ldy,dy,Ldz,dz,t,C_sat,writerObj)
% plot the result, create a isosurface
% the user could add any other plots freely

clf
isosurface(X,Y,Z,C,C_sat)
axis equal
xlabel('X')
ylabel('Y')
zlabel('Z')
xlim([-Ldx/2+dx,Ldx/2-dx])
ylim([-Ldy/2+dy,Ldy/2-dy])
zlim([-Ldz/2+dz,Ldz/2-dz])
title ( sprintf ('t =% 1.4f',t));
colorbar
caxis([0 C_sat])
drawnow

% take frame for movie generate
frame = getframe(gcf);
writeVideo(writerObj,frame);
end