% Boundary condition type and value 
% BC type: 1 is Dirichlet BC, 2 is Neuman BC
BCa_type = 1; % on top surface with normal vector = [0,0,1]
BCb_type = 1; % on bottom surface with normal vector = {0,0,-1}
BCc_type = 1; % on the side surface with normal vector = {1,0,0}
BCd_type = 1; % on the side surface with normal vector = {-1,0,0}
BCe_type = 1; % on the side surface with normal vector = {0,1,0}
BCf_type = 1; % on the side surface with normal vector = {0,-1,0}

BCa_value = 0; % on top surface with normal vector = [0,0,1]
BCb_value = 0; % on bottom surface with normal vector = {0,0,-1}
BCc_value = 0; % on the side surface with normal vector = {1,0,0}
BCd_value = 0; % on the side surface with normal vector = {-1,0,0}
BCe_value = 0; % on the side surface with normal vector = {0,1,0}
BCf_value = 0; % on the side surface with normal vector = {0,-1,0}

% Apply nonlocal Boundary Conditions with fictitious nodes method:
% Force all fictitious nodes outside physical domain has C=0
w = zeros(Nx,Ny,Nz);
% apply boundary condition on top surface with normal vector = [0,0,1]
gBCa = (z_max_T - 2*delta < Z & Z < z_max_T - delta);
n1 = find(gBCa(1,1,:));
w(:,:,Nz - size(n1,1) + 1:Nz)=assemble_BC(BCa_type,BCa_value,Z(:,:,Nz - size(n1,1) + 1:Nz),C0(:,:,n1(end):-1:n1(1)),Lz_T/2 - delta);

% apply Dirichlet boundary condition on bottom surface with normal vector = [0,0,-1]
gBCb = (z_min_T + delta < Z & Z < z_min_T + 2*delta + dz);
n2 = find(gBCb(1,1,:));
w(:,:,1:size(n2,1)) = assemble_BC(BCb_type,BCb_value,Z(:,:,1:size(n2,1)),C0(:,:,n2(end):-1:n2(1)),-Lz_T/2 + delta);

% apply boundary condition on side surface with normal vector = [1,0,0]
gBCc = (x_max_T - 2*delta  < X & X < x_max_T - delta);
n3 = find(gBCc(1,:,1));
w(:, Nx - size(n3,2)+1:Nx,:) = assemble_BC(BCc_type,BCc_value,X(:, Nx - size(n3,2) + 1:Nx,:),C0(:,n3(end):-1:n3(1),:),Lx_T/2-delta);

% apply boundary condition on side surface with normal vector = [-1,0,0]
gBCd = (x_min_T + delta < X & X < x_min_T + 2*delta + dx);
n4 = find(gBCd(1,:,1));
w(:,1:size(n4,2),:) = assemble_BC(BCd_type,BCd_value,X(:,1:size(n4,2),:),C0(:,n4(end):-1:n4(1),:),-Lx_T/2 + delta);

% apply boundary condition on side surface with normal vector = [0,1,0]
gBCe = (y_max_T - 2*delta < Y & Y < y_max_T - delta);
n5 = find(gBCe(:,1,1));
w(Ny - size(n5,1) + 1:Ny,:,:) = assemble_BC(BCe_type,BCe_value,Y(Ny - size(n5,1) + 1:Ny,:,:), C0(n5(end):-1:n5(1),:,:), Ly_T/2 - delta) ;

% apply boundary condition on side surface with normal vector = [0,-1,0]
gBCf = (y_min_T + delta < Y & Y < y_min_T + 2*delta + dy);
n6 = find(gBCf(:,1,1));
w(1:size(n6,1),:,:) = assemble_BC(BCf_type,BCf_value,Y(1:size(n6,1),:,:),C0(n6(end):-1:n6(1),:,:),-Ly_T/2 + delta);

C = chi.*C0 + (1 - chi).*w;
function A = assemble_BC(BC_type,BC_value,B,C,value)
    if(BC_type == 1)
        A = 2*BC_value - C;
    elseif(BC_type == 2)
        A = 2*BC_value*(B-value)+C;
    else
        error('This BC type is not supported');
    end
end
