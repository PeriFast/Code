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
gBCa = (z_max - delta < Z & Z < z_max);
n1 = find(gBCa(1,1,:));

% apply boundary condition on bottom surface with normal vector = [0,0,-1]
gBCb = (z_min < Z & Z < z_min + delta + dz);
n2 = find(gBCb(1,1,:));

% apply boundary condition on side surface with normal vector = [1,0,0]
gBCc = (x_max - delta  < X & X < x_max);
n3 = find(gBCc(1,:,1));

% apply boundary condition on side surface with normal vector = [-1,0,0]
gBCd = (x_min < X & X < x_min + delta + dx);
n4 = find(gBCd(1,:,1));

% apply boundary condition on side surface with normal vector = [0,1,0]
gBCe = (y_max - delta < Y & Y < y_max);
n5 = find(gBCe(:,1,1));

% apply boundary condition on side surface with normal vector = [0,-1,0]
gBCf = (y_min < Y & Y < y_min + delta + dy);
n6 = find(gBCf(:,1,1));

C = chi.*C0 + (1 - chi).*w;
