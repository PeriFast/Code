function [wx,wy,wz] =...
    update_VC(dispBC_x,dispBC_y,dispBC_z,chiG_x,chiG_y,chiG_z,...
    Nx,Ny,Nz,X,Y,Z,t)

wx = assemble_BC(chiG_x,dispBC_x,Nx,Ny,Nz,X,Y,Z,t);
wy = assemble_BC(chiG_y,dispBC_y,Nx,Ny,Nz,X,Y,Z,t);
wz = assemble_BC(chiG_z,dispBC_z,Nx,Ny,Nz,X,Y,Z,t);

end

function combined_BC = assemble_BC(BC_sets,BC_values,Nx,Ny,Nz,X,Y,Z,t)
combined_BC = zeros(Ny,Nx,Nz);
n = BC_sets.No;
for i = 1:n(1)
    combined_BC = combined_BC +...
        (BC_sets(i).set).*(BC_values(i).func(X,Y,Z,t));
end
end