% at every second
% plot the result, create a 2D slice normal to z direction
% output the concentration data to tecplot
if (is_plot_in_Matlab == 1 && mod(t,t_plot) == 0)
    
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

end
if (is_output_to_Tecplot == 1 && abs(t-t_target) <= dt)
    % output data to tecplot
    tec_tmp = tec_tmp + 1;
    tdata.cubes(tec_tmp).x=X;
    tdata.cubes(tec_tmp).y=Y;
    tdata.cubes(tec_tmp).z=Z;
    tdata.cubes(tec_tmp).v(1,:,:,:)=chi_l;
    t_target = t_target + t_output;
end