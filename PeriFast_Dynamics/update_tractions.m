function [btx,bty,btz] =...
    update_tractions(trac_x,trac_y,trac_z,chit_x,chit_y,chit_z,...
    delta,Nx,Ny,Nz,X,Y,Z,t,dy)

btx = assemble_BC(chit_x,trac_x,Nx,Ny,Nz,X,Y,Z,t)/delta;
bty = assemble_BC(chit_y,trac_y,Nx,Ny,Nz,X,Y,Z,t)/delta;
% bty = assemble_BC(chit_y,trac_y,Nx,Ny,Nz,X,Y,Z,t)/dy;

btz = assemble_BC(chit_z,trac_z,Nx,Ny,Nz,X,Y,Z,t)/delta;

end

function combined_BC = assemble_BC(BC_sets,BC_values,Nx,Ny,Nz,X,Y,Z,t)
combined_BC = zeros(Ny,Nx,Nz);
n = BC_sets.No;
for i = 1:n(1)
    combined_BC = combined_BC +...
        (BC_sets(i).set).*(BC_values(i).func(X,Y,Z,t));
end
end