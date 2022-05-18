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
gBCa = (z_max - 2*delta < Z & Z < z_max - delta);
n1 = find(gBCa(1,1,:));
if(BCa_type == 1)
    w(:,:,Nz - size(n1,1) + 1:Nz) = 2*BCa_value - C0(:,:,n1(end):-1:n1(1)); %Dir
elseif(BCa_type == 2)
    w(:,:,Nz - size(n1,1) + 1:Nz) = 2*BCa_value*(Z(:,:,Nz - size(n1,1) + 1:Nz)...
        -(Lz/2 - delta)) + C0(:,:,n1(end):-1:n1(1)); %Neu
else
    error('BCa_type is not valid');
end

% apply Dirichlet boundary condition on bottom surface with normal vector = [0,0,-1]
gBCb = (z_min + delta < Z & Z < z_min + 2*delta + dz);
n2 = find(gBCb(1,1,:));
if(BCb_type == 1)
    w(:,:,1:size(n2,1)) = 2*BCb_value - C0(:,:,n2(end):-1:n2(1)); %Dir
elseif(BCb_type == 2)
    w(:,:,1:size(n2,1)) = -2*BCb_value*((-Lz/2 + delta) - Z(:,:,1:size(n2,1)))...
    + C0(:,:,n2(end):-1:n2(1)); %Neu
else
    error('BCb_type is not valid');
end

% apply Dirichlet boundary condition on side surface with normal vector = [1,0,0]
gBCc = (x_max - 2*delta  < X & X < x_max - delta);
n3 = find(gBCc(1,:,1));
if(BCc_type == 1)
    w(:, Nx - size(n3,2)+1:Nx,:) = 2*BCc_value - C0(:,n3(end):-1:n3(1),:);
elseif(BCc_type == 2)
    w(:, Nx - size(n3,2)+1:Nx,:) = 2*BCc_value*(X(:, Nx - size(n3,2) + 1:...
        Nx,:) - (Lx/2-delta)) + C0(:,n3(end):-1:n3(1),:);
else
    error('BCc_type is not valid');
end

% apply Dirichlet boundary condition on side surface with normal vector = [-1,0,0]
gBCd = (x_min + delta < X & X < x_min + 2*delta + dx);
n4 = find(gBCd(1,:,1));
if(BCd_type == 1)
    w(:,1:size(n4,2),:) = 2*BCd_value - C0(:,n4(end):-1:n4(1),:);
elseif(BCd_type == 2)
    w(:,1:size(n4,2),:) = -2*BCd_value*((-Lx/2 + delta) - X(:,1:size(n4,2),...
        :)) + C0(:,n4(end):-1:n4(1),:);
else
    error('BCd_type is not valid');
end

% apply Dirichlet boundary condition on side surface with normal vector = [0,1,0]
gBCe = (y_max - 2*delta < Y & Y < y_max - delta);
n5 = find(gBCe(:,1,1));
if(BCe_type == 1)
    w(Ny - size(n5,1) + 1:Ny,:,:) = 2*BCe_value - C0(n5(end):-1:n5(1),:,:);
elseif(BCe_type == 2)
    w(Ny - size(n5,1) + 1:Ny,:,:) = 2*BCe_value*(Y(Ny - size(n5,1) + 1:Ny,...
        :,:) -(Ly/2 - delta)) + C0(n5(end):-1:n5(1),:,:);
else
    error('BCe_type is not valid');
end

% apply Dirichlet boundary condition on side surface with normal vector = [0,-1,0]
gBCf = (y_min + delta < Y & Y < y_min + 2*delta + dy);
n6 = find(gBCf(:,1,1));
if(BCf_type == 1)
    w(1:size(n6,1),:,:) = 2*BCf_value - C0(n6(end):-1:n6(1),:,:);
elseif(BCf_type == 2)
    w(1:size(n6,1),:,:) = -2*BCf_value*((-Ly/2 + delta) - Y(1:size(n6,1),...
        :,:)) + C0(n6(end):-1:n6(1),:,:);
else
    error('BCf_type is not valid');
end

C = chi.*C0 + (1 - chi).*w;