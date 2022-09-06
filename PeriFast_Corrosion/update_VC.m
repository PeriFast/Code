function C_w = update_VC(C_w,C,Nx,Ny,Nz,n1,n2,n3,n4,n5,n6,X,Y,Z,Lx_T,Ly_T,Lz_T,delta,BC_type,BC_value)
% Update volume constraints C_w(x,t) according to the given local boundary conditions:
C_w(:,:,Nz - size(n1,1) + 1:Nz)=assemble_BC(BC_type(1),BC_value(1),Z(:,:,Nz - size(n1,1) + 1:Nz)-(Lz_T/2 - delta),C(:,:,n1(end):-1:n1(1)));
C_w(:,:,1:size(n2,1)) = assemble_BC(BC_type(2),BC_value(2),Z(:,:,1:size(n2,1))-(-Lz_T/2 + delta),C(:,:,n2(end):-1:n2(1)));
C_w(:, Nx - size(n3,2)+1:Nx,:) = assemble_BC(BC_type(3),BC_value(3),X(:, Nx - size(n3,2) + 1:Nx,:)-(Lx_T/2-delta),C(:,n3(end):-1:n3(1),:));
C_w(:,1:size(n4,2),:) = assemble_BC(BC_type(4),BC_value(4),X(:,1:size(n4,2),:)-(-Lx_T/2 + delta),C(:,n4(end):-1:n4(1),:));
C_w(Ny - size(n5,1) + 1:Ny,:,:) = assemble_BC(BC_type(5),BC_value(5),Y(Ny - size(n5,1) + 1:Ny,:,:)-(Ly_T/2 - delta), C(n5(end):-1:n5(1),:,:)) ;
C_w(1:size(n6,1),:,:) = assemble_BC(BC_type(6),BC_value(6),Y(1:size(n6,1),:,:)-(-Ly_T/2 + delta),C(n6(end):-1:n6(1),:,:));
end
function volume_constraint = assemble_BC(BC_type,BC_value,distance_from_boundary,concentration_inside_boundary)
    %based on fictitious node method
    if(BC_type == 1)
        volume_constraint = 2*BC_value - concentration_inside_boundary;
    elseif(BC_type == 2)
        volume_constraint = 2*BC_value*distance_from_boundary + concentration_inside_boundary;
    else
        error('This BC type is not supported');
    end
end