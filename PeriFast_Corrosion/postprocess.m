%user can use this script to postprocess the stored matlab data
load('Results.mat');
output_size = size(Output,2);
writerObj=VideoWriter('bigN_corrosion');
open(writerObj);
for i = 1:output_size
    visualization(X,Y,Z,Output(i).C,Ldx,dx,Ldy,dy,Ldz,dz,Output(i).t,C_sat,0,writerObj);
end
close(writerObj);