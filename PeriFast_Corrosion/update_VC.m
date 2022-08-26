% Update volume constraints w(x,t) according to the given local boundary conditions:
w(:,:,Nz - size(n1,1) + 1:Nz)=assemble_BC(BCa_type,BCa_value,Z(:,:,Nz - size(n1,1) + 1:Nz),C(:,:,n1(end):-1:n1(1)),Lz_T/2 - delta);
w(:,:,1:size(n2,1)) = assemble_BC(BCb_type,BCb_value,Z(:,:,1:size(n2,1)),C(:,:,n2(end):-1:n2(1)),-Lz_T/2 + delta);
w(:, Nx - size(n3,2)+1:Nx,:) = assemble_BC(BCc_type,BCc_value,X(:, Nx - size(n3,2) + 1:Nx,:),C(:,n3(end):-1:n3(1),:),Lx_T/2-delta);
w(:,1:size(n4,2),:) = assemble_BC(BCd_type,BCd_value,X(:,1:size(n4,2),:),C(:,n4(end):-1:n4(1),:),-Lx_T/2 + delta);
w(Ny - size(n5,1) + 1:Ny,:,:) = assemble_BC(BCe_type,BCe_value,Y(Ny - size(n5,1) + 1:Ny,:,:), C(n5(end):-1:n5(1),:,:), Ly_T/2 - delta) ;
w(1:size(n6,1),:,:) = assemble_BC(BCf_type,BCf_value,Y(1:size(n6,1),:,:),C(n6(end):-1:n6(1),:,:),-Ly_T/2 + delta);

function A = assemble_BC(BC_type,BC_value,B,C,value)
    if(BC_type == 1)
        A = 2*BC_value - C;
    elseif(BC_type == 2)
        A = 2*BC_value*(B-value)+C;
    else
        error('This BC type is not supported');
    end
end