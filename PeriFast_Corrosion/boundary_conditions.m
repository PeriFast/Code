% Boundary condition type and value 
% BC type: 1 is Dirichlet BC, 2 is Neuman BC
BC1_type = 1; % on top surface with normal vector = [0,0,1]
BC2_type = 1; % on bottom surface with normal vector = {0,0,-1}
BC3_type = 1; % on the side surface with normal vector = {1,0,0}
BC4_type = 1; % on the side surface with normal vector = {-1,0,0}
BC5_type = 1; % on the side surface with normal vector = {0,1,0}
BC6_type = 1; % on the side surface with normal vector = {0,-1,0}
BC_type = [BC1_type,BC2_type,BC3_type,BC4_type,BC5_type,BC6_type];

BC1_value = 0; % on top surface with normal vector = [0,0,1]
BC2_value = 0; % on bottom surface with normal vector = {0,0,-1}
BC3_value = 0; % on the side surface with normal vector = {1,0,0}
BC4_value = 0; % on the side surface with normal vector = {-1,0,0}
BC5_value = 0; % on the side surface with normal vector = {0,1,0}
BC6_value = 0; % on the side surface with normal vector = {0,-1,0}
BC_value = [BC1_value,BC2_value,BC3_value,BC4_value,BC5_value,BC6_value];

% Apply nonlocal Boundary Conditions with fictitious nodes method:
% Force all fictitious nodes outside physical domain has C=0
C_w = zeros(Nx,Ny,Nz);
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

boundary_condition_check(BC_type);
C = chi.*C0 + (1 - chi).*C_w;
function boundary_condition_check(BC_type)
for i = 1:length(BC_type)
    if(BC_type(i) ~=1 && BC_type(i)~=2)
        error('The BC type no.%d is not supported',i);
    end
end
end