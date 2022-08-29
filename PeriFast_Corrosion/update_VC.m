% Update volume constraints w(x,t) according to the given local boundary conditions:
w(:,:,Nz - size(n1,1) + 1:Nz)=assemble_BC(BCa_type,BCa_value,Z(:,:,Nz - size(n1,1) + 1:Nz)-(Lz_T/2 - delta),C(:,:,n1(end):-1:n1(1)));
w(:,:,1:size(n2,1)) = assemble_BC(BCb_type,BCb_value,Z(:,:,1:size(n2,1))-(-Lz_T/2 + delta),C(:,:,n2(end):-1:n2(1)));
w(:, Nx - size(n3,2)+1:Nx,:) = assemble_BC(BCc_type,BCc_value,X(:, Nx - size(n3,2) + 1:Nx,:)-(Lx_T/2-delta),C(:,n3(end):-1:n3(1),:));
w(:,1:size(n4,2),:) = assemble_BC(BCd_type,BCd_value,X(:,1:size(n4,2),:)-(-Lx_T/2 + delta),C(:,n4(end):-1:n4(1),:));
w(Ny - size(n5,1) + 1:Ny,:,:) = assemble_BC(BCe_type,BCe_value,Y(Ny - size(n5,1) + 1:Ny,:,:)-(Ly_T/2 - delta), C(n5(end):-1:n5(1),:,:)) ;
w(1:size(n6,1),:,:) = assemble_BC(BCf_type,BCf_value,Y(1:size(n6,1),:,:)-(-Ly_T/2 + delta),C(n6(end):-1:n6(1),:,:));

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