function [tdata] = dump_output_Tecplot(tdata,X,Y,Z,C,run_in_gpu,tec_step)

if(run_in_gpu == 1)
    tdata.cubes(tec_step).x=gather(X);
    tdata.cubes(tec_step).y=gather(Y);
    tdata.cubes(tec_step).z=gather(Z);
    tdata.cubes(tec_step).v(1,:,:,:)=gather(C);
else
    tdata.cubes(tec_step).x=X;
    tdata.cubes(tec_step).y=Y;
    tdata.cubes(tec_step).z=Z;
    tdata.cubes(tec_step).v(1,:,:,:)=C;
end
end

