% %output to tecplot file
if (is_output_to_Tecplot == 1)
    tdata=[];
    tdata.Nvar=4;
    tdata.varnames={'x','y','z','L'};
    tdata.cubes(1).zonename='mysurface zone';
    %totally nodes [3x2x2]
    tdata.cubes(1).x=X;
    tdata.cubes(1).y=Y;
    tdata.cubes(1).z=Z;
    tdata.cubes(1).v(1,:,:,:)=chi_l;
    tec_tmp = 1;
end

%generate output movie
if (is_plot_in_Matlab == 1)
    writerObj=VideoWriter('bigN_pit.avVi');
    open(writerObj);
end