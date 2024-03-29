function [L1, L2, L3, W, history_var] = ...
    constitutive(props,u1,u2,u3,history_var,delta,constit_invar,chiB,dv, Nx,Ny,Nz, run_in_gpu)
% This function takes the displacement field, history-dependent variables
% such as the old damage parameter, the material properties (defined in 
% inputs.m), discretization info (defined in nodes_and_sets.m), and the
% invariant terms in the constitutive response (from pre_constitutive.m)
% as inputs, and returns the internal force density, strain energy density,
% and updated history-dependnet variables(e.g. damage) as outputs

mat_type = props(1); % material model


% bond_based PD model
if mat_type == 0
    % re-assign transformed adjusted kernels
    C11s_hat = constit_invar.C11s_hat; C12s_hat = constit_invar.C12s_hat;
    C13s_hat = constit_invar.C13s_hat; C22s_hat = constit_invar.C22s_hat;
    C23s_hat = constit_invar.C23s_hat; C33s_hat = constit_invar.C33s_hat;
    C21s_hat = C12s_hat; C31s_hat = C13s_hat; C32s_hat = C23s_hat;
    
    % compute repeated terms
    lambda = history_var.lambda;
    chiB_lambda = chiB.*lambda;
    chiB_lambda_hat = fftn(chiB_lambda);
    chiB_lambda_u1_hat = fftn(chiB_lambda.*u1);
    chiB_lambda_u2_hat = fftn(chiB_lambda.*u2);
    chiB_lambda_u3_hat = fftn(chiB_lambda.*u3);
    
    chiB_lambda_u1u1_hat = fftn(chiB_lambda.*u1.*u1);
    chiB_lambda_u1u2_hat = fftn(chiB_lambda.*u1.*u2);
    chiB_lambda_u1u3_hat = fftn(chiB_lambda.*u1.*u3);
    chiB_lambda_u2u2_hat = fftn(chiB_lambda.*u2.*u2);
    chiB_lambda_u2u3_hat = fftn(chiB_lambda.*u2.*u3);
    chiB_lambda_u3u3_hat = fftn(chiB_lambda.*u3.*u3);
    
    % compute internal force density (Li)
    L1 = dv*(chiB_lambda.*(ifftn(C11s_hat.*chiB_lambda_u1_hat + ...
        C12s_hat.*chiB_lambda_u2_hat + C13s_hat.*chiB_lambda_u3_hat))-...
        ifftn(C11s_hat.*chiB_lambda_hat).*chiB_lambda.*u1 - ...
        ifftn(C12s_hat.*chiB_lambda_hat).*chiB_lambda.*u2 - ...
        ifftn(C13s_hat.*chiB_lambda_hat).*chiB_lambda.*u3);
    
    L2 = dv*(chiB_lambda.*(ifftn(C21s_hat.*chiB_lambda_u1_hat +...
        C22s_hat.*chiB_lambda_u2_hat + C23s_hat.*chiB_lambda_u3_hat))-...
        ifftn(C21s_hat.*chiB_lambda_hat).*chiB_lambda.*u1 -...
        ifftn(C22s_hat.*chiB_lambda_hat).*chiB_lambda.*u2  -...
        ifftn(C23s_hat.*chiB_lambda_hat).*chiB_lambda.*u3);
    
    L3 = dv*(chiB_lambda.*(ifftn(C31s_hat.*chiB_lambda_u1_hat +...
        C32s_hat.*chiB_lambda_u2_hat + C33s_hat.*chiB_lambda_u3_hat))-...
        ifftn(C31s_hat.*chiB_lambda_hat).*chiB_lambda.*u1 -...
        ifftn(C32s_hat.*chiB_lambda_hat).*chiB_lambda.*u2  -...
        ifftn(C33s_hat.*chiB_lambda_hat).*chiB_lambda.*u3);

    %%% strain enegry density (W)
    
    % compute W
    W = 0.25*dv*chiB_lambda.*(ifftn(C11s_hat.*chiB_lambda_u1u1_hat + ...
        2*C12s_hat.*chiB_lambda_u1u2_hat + 2*C13s_hat.*chiB_lambda_u1u3_hat +...
        C22s_hat.*chiB_lambda_u2u2_hat + 2* C23s_hat.*chiB_lambda_u2u3_hat +...
        C33s_hat.*chiB_lambda_u3u3_hat) - ...
        2*(ifftn(C11s_hat.*chiB_lambda_u1_hat).*u1 +...
        ifftn(C12s_hat.*chiB_lambda_u1_hat).*u2 +...
        ifftn(C13s_hat.*chiB_lambda_u1_hat).*u3 +...
        ifftn(C21s_hat.*chiB_lambda_u2_hat).*u1 +...
        ifftn(C22s_hat.*chiB_lambda_u2_hat).*u2+...
        ifftn(C23s_hat.*chiB_lambda_u2_hat).*u3 +...
        ifftn(C31s_hat.*chiB_lambda_u3_hat).*u1 +...
        ifftn(C32s_hat.*chiB_lambda_u3_hat).*u2 +...
        ifftn(C33s_hat.*chiB_lambda_u3_hat).*u3 ) +...
        ifftn(C11s_hat.*chiB_lambda_hat).*u1.*u1 + ...
        2*(ifftn(C12s_hat.*chiB_lambda_hat).*u1.*u2) +...
        2*(ifftn(C13s_hat.*chiB_lambda_hat).*u1.*u3) +...
        ifftn(C22s_hat.*chiB_lambda_hat).*u2.*u2 +...
        2*(ifftn(C23s_hat.*chiB_lambda_hat).*u2.*u3) +...
        ifftn(C33s_hat.*chiB_lambda_hat).*u3.*u3 );
    %%% update lambda according to the damage model
    G0 = props(3);
    lambda( W >= G0/(2*delta) ) = 0;
    history_var.lambda = lambda;
    
    %%% update damage index
    omega0s_hat = constit_invar.omega0s_hat;
    chiB_hat = fftn(chiB);
    numerator = chiB_lambda.*ifftn(chiB_lambda_hat.*omega0s_hat);
    denominator = chiB.*ifftn(chiB_hat.*omega0s_hat);
    denominator(denominator == 0) = 1; %avoid division by zero
    
    history_var.damage = 1 - numerator./denominator;
end

% state_based PD model
if mat_type == 1
    % re-assign transformed adjusted kernels
    C11s_hat = constit_invar.C11s_hat; C12s_hat = constit_invar.C12s_hat;
    C13s_hat = constit_invar.C13s_hat; C22s_hat = constit_invar.C22s_hat;
    C23s_hat = constit_invar.C23s_hat; C33s_hat = constit_invar.C33s_hat;
    C21s_hat = C12s_hat; C31s_hat = C13s_hat; C32s_hat = C23s_hat;
    
    % compute repeated terms
    lambda = history_var.lambda;
    chiB_lambda = chiB.*lambda;
    chiB_lambda_hat = fftn(chiB_lambda);
    chiB_lambda_u1_hat = fftn(chiB_lambda.*u1);
    chiB_lambda_u2_hat = fftn(chiB_lambda.*u2);
    chiB_lambda_u3_hat = fftn(chiB_lambda.*u3);
        
    chiB_lambda_u1u1_hat = fftn(chiB_lambda.*u1.*u1);
    chiB_lambda_u1u2_hat = fftn(chiB_lambda.*u1.*u2);
    chiB_lambda_u1u3_hat = fftn(chiB_lambda.*u1.*u3);
    chiB_lambda_u2u2_hat = fftn(chiB_lambda.*u2.*u2);
    chiB_lambda_u2u3_hat = fftn(chiB_lambda.*u2.*u3);
    chiB_lambda_u3u3_hat = fftn(chiB_lambda.*u3.*u3);
    
    % re-assign transformed adjusted kernels
    A1s_hat = constit_invar.A1s_hat; 
    A2s_hat = constit_invar.A2s_hat;
    A3s_hat = constit_invar.A3s_hat;
    m_kernels_hat = constit_invar.m_kernels_hat;
    
    m = chiB_lambda.*ifftn(chiB_lambda_hat.*m_kernels_hat,'symmetric')*dv;
    m(m == 0) = 1; % avoid division by zero outside the body where chi_B = 0
    
    E = props(4);% Young modulus
    nu = props (5);% Poisson ratio
    K = E/(3*(1 - 2*nu)); % bulk modulus
    G = E/(2*(1 + nu)); % shear modulus
    
    % PD dilatation
    theta = (3./m).*chiB_lambda.*(-ifftn(A1s_hat.*chiB_lambda_u1_hat +...
        A2s_hat.*chiB_lambda_u2_hat + A3s_hat.*chiB_lambda_u3_hat,'symmetric') + ...
        u1.*ifftn(A1s_hat.*chiB_lambda_hat,'symmetric') + ...
        u2.*ifftn(A2s_hat.*chiB_lambda_hat,'symmetric') + ...
        u3.*ifftn(A3s_hat.*chiB_lambda_hat,'symmetric'))*dv;
    
    chiB_lambda_theta_hat = fftn(chiB_lambda.*theta);
    
    % compute internal force density (Li)
    L1 = dv.*chiB_lambda.*(((3*K - 5*G)./m).*(-theta.*ifftn(A1s_hat.*chiB_lambda_hat,'symmetric') -...
        ifftn(A1s_hat.*chiB_lambda_theta_hat,'symmetric')) + ...
        (1./m).*(ifftn(C11s_hat.*chiB_lambda_u1_hat,'symmetric') +...
        ifftn(C12s_hat.*chiB_lambda_u2_hat,'symmetric') +...
        ifftn(C13s_hat.*chiB_lambda_u3_hat,'symmetric') - ...
        u1.*ifftn(C11s_hat.*chiB_lambda_hat,'symmetric') - ...
        u2.*ifftn(C12s_hat.*chiB_lambda_hat,'symmetric')- ...
        u3.*ifftn(C13s_hat.*chiB_lambda_hat,'symmetric')));
    
    L2 =  dv.*chiB_lambda.*(((3*K - 5*G)./m).*(-theta.*ifftn(A2s_hat.*chiB_lambda_hat,'symmetric') -...
        ifftn(A2s_hat.*chiB_lambda_theta_hat,'symmetric')) + ...
        (1./m).*(ifftn(C21s_hat.*chiB_lambda_u1_hat,'symmetric') +...
        ifftn(C22s_hat.*chiB_lambda_u2_hat,'symmetric') + ...
        ifftn(C23s_hat.*chiB_lambda_u3_hat,'symmetric') - ...
        u1.*ifftn(C21s_hat.*chiB_lambda_hat,'symmetric') - ...
        u2.*ifftn(C22s_hat.*chiB_lambda_hat,'symmetric')- ...
        u3.*ifftn(C23s_hat.*chiB_lambda_hat,'symmetric')));
    
    L3 = dv.*chiB_lambda.*(((3*K - 5*G)./m).*(-theta.*ifftn(A3s_hat.*chiB_lambda_hat,'symmetric') -...
        ifftn(A3s_hat.*chiB_lambda_theta_hat,'symmetric')) + ...
        (1./m).*(ifftn(C31s_hat.*chiB_lambda_u1_hat,'symmetric') +...
        ifftn(C32s_hat.*chiB_lambda_u2_hat,'symmetric') + ...
        ifftn(C33s_hat.*chiB_lambda_u3_hat,'symmetric') - ...
        u1.*ifftn(C31s_hat.*chiB_lambda_hat,'symmetric') -...
        u2.*ifftn(C32s_hat.*chiB_lambda_hat,'symmetric')- ...
        u3.*ifftn(C33s_hat.*chiB_lambda_hat,'symmetric')));
    
    %%% strain enegry density (W)

    % compute W
    W = 0.5*(dv*chiB_lambda.*(1./(2*m)).*(ifftn(C11s_hat.*chiB_lambda_u1u1_hat + ...
        2*C12s_hat.*chiB_lambda_u1u2_hat + 2*C13s_hat.*chiB_lambda_u1u3_hat +...
        C22s_hat.*chiB_lambda_u2u2_hat + 2* C23s_hat.*chiB_lambda_u2u3_hat +...
        C33s_hat.*chiB_lambda_u3u3_hat) - ...
        2*(ifftn(C11s_hat.*chiB_lambda_u1_hat).*u1 +...
        ifftn(C12s_hat.*chiB_lambda_u1_hat).*u2 +...
        ifftn(C13s_hat.*chiB_lambda_u1_hat).*u3 +...
        ifftn(C21s_hat.*chiB_lambda_u2_hat).*u1 +...
        ifftn(C22s_hat.*chiB_lambda_u2_hat).*u2+...
        ifftn(C23s_hat.*chiB_lambda_u2_hat).*u3 +...
        ifftn(C31s_hat.*chiB_lambda_u3_hat).*u1 +...
        ifftn(C32s_hat.*chiB_lambda_u3_hat).*u2 +...
        ifftn(C33s_hat.*chiB_lambda_u3_hat).*u3 ) +...
        ifftn(C11s_hat.*chiB_lambda_hat).*u1.*u1 + ...
        2*(ifftn(C12s_hat.*chiB_lambda_hat).*u1.*u2) +...
        2*(ifftn(C13s_hat.*chiB_lambda_hat).*u1.*u3) +...
        ifftn(C22s_hat.*chiB_lambda_hat).*u2.*u2 +...
        2*(ifftn(C23s_hat.*chiB_lambda_hat).*u2.*u3) +...
        ifftn(C33s_hat.*chiB_lambda_hat).*u3.*u3 ) + (K - 5*G/3).*theta.^2);
    
    %%% update lambda according to the damage model
    G0 = props(3);
    lambda( W >= G0/(2*delta) ) = 0;
    history_var.lambda = lambda;
    
    %%% update damage index
    omega0s_hat = constit_invar.omega0s_hat;
    chiB_hat = fftn(chiB);
    numerator = chiB_lambda.*ifftn(chiB_lambda_hat.*omega0s_hat);
    denominator = chiB.*ifftn(chiB_hat.*omega0s_hat);
    denominator(denominator == 0) = 1; %avoid division by zero
    
    history_var.damage = 1 - numerator./denominator;
    
end

% corresspondence PD model
if mat_type == 2
    % re-assign transformed adjusted kernels
    C11s_hat = constit_invar.C11s_hat; C12s_hat = constit_invar.C12s_hat;
    C13s_hat = constit_invar.C13s_hat; C22s_hat = constit_invar.C22s_hat;
    C23s_hat = constit_invar.C23s_hat; C33s_hat = constit_invar.C33s_hat;
    
    % compute repeated terms
    lambda = history_var.lambda;
    chiB_lambda = chiB.*lambda;
    chiB_lambda_hat = fftn(chiB_lambda);
    chiB_lambda_u1_hat = fftn(chiB_lambda.*u1);
    chiB_lambda_u2_hat = fftn(chiB_lambda.*u2);
    chiB_lambda_u3_hat = fftn(chiB_lambda.*u3);
    
    % re-assign transformed adjusted kernels
    A1s_hat = constit_invar.A1s_hat; A2s_hat = constit_invar.A2s_hat;A3s_hat = constit_invar.A3s_hat;
    omega0s_hat = constit_invar.omega0s_hat;
    chiB_lambda_A1s_hat_invfft = ifftn(chiB_lambda_hat.*A1s_hat,'symmetric');
    chiB_lambda_A2s_hat_invfft = ifftn(chiB_lambda_hat.*A2s_hat,'symmetric');
    chiB_lambda_A3s_hat_invfft = ifftn(chiB_lambda_hat.*A3s_hat,'symmetric');
    
    % related to stabilizer (in Silling 2017)
    omega_stab = chiB_lambda.*ifftn(chiB_lambda_hat.*omega0s_hat,'symmetric')*dv;
    E = props(4);% Young modulus
    nu = props (5);% Poisson ratio
    K = E/(3*(1 - 2*nu)); % bulk modulus
    G = E/(2*(1 + nu)); % shear modulus
    const = 0.5*dv*18*K/(pi*delta^5);% for stabilizer
    beta_stab = const./(omega_stab +(omega_stab==0));% for stabilizer
    
    % compute shape_tensor K
    K11_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C11s_hat,'symmetric'))*dv;
    K12_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C12s_hat,'symmetric'))*dv;
    K13_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C13s_hat,'symmetric'))*dv;
    K22_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C22s_hat,'symmetric'))*dv;
    K23_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C23s_hat,'symmetric'))*dv;
    K33_shape = chiB_lambda.*(ifftn(chiB_lambda_hat .* C33s_hat,'symmetric'))*dv;
    
    % compute inverse shape_tensor
    
    if (history_var.t == 0)%if first time step, allocate memory for inverse K and compute K_inv:
        K11_shape_inv = zeros(Ny,Nx,Nz);K12_shape_inv = zeros(Ny,Nx,Nz);K13_shape_inv = zeros(Ny,Nx,Nz);
        K21_shape_inv = zeros(Ny,Nx,Nz);K22_shape_inv = zeros(Ny,Nx,Nz);K23_shape_inv = zeros(Ny,Nx,Nz);
        K31_shape_inv = zeros(Ny,Nx,Nz);K32_shape_inv = zeros(Ny,Nx,Nz);K33_shape_inv = zeros(Ny,Nx,Nz);
        K_update = ones(Ny,Nx,Nz);% to update K for all nodes if t=0
        %compute initial damage at t=0:
        chiB_hat = fftn(chiB);
        numerator = chiB_lambda.*ifftn(chiB_lambda_hat.*omega0s_hat);
        denominator = chiB.*ifftn(chiB_hat.*omega0s_hat);
        denominator(denominator == 0) = 1; %avoid division by zero
        history_var.damage = 1 - numerator./denominator;
        
        
    else % use K_inv values from previous step
        K11_shape_inv =  history_var.K_inv11;
        K12_shape_inv =  history_var.K_inv12;
        K13_shape_inv =  history_var.K_inv13;
        K21_shape_inv =  history_var.K_inv12;
        K22_shape_inv =  history_var.K_inv22;
        K23_shape_inv =  history_var.K_inv23;
        K31_shape_inv =  history_var.K_inv13;
        K32_shape_inv =  history_var.K_inv23;
        K33_shape_inv =  history_var.K_inv33;
        K_update = history_var.K_update;
    end
    if run_in_gpu ==1
        %gather K-shapes for calculation of inv(k)
        K11_shape = gather(K11_shape);
        K12_shape = gather(K12_shape);
        K13_shape = gather(K13_shape);
        K22_shape = gather(K22_shape);
        K23_shape = gather(K23_shape);
        K33_shape = gather(K33_shape);
        K11_shape_inv = gather(K11_shape_inv);
        K12_shape_inv = gather(K12_shape_inv);
        K13_shape_inv = gather(K13_shape_inv);
        K21_shape_inv = gather(K21_shape_inv);
        K22_shape_inv = gather(K22_shape_inv);
        K23_shape_inv = gather(K23_shape_inv);
        K31_shape_inv = gather(K31_shape_inv);
        K32_shape_inv = gather(K32_shape_inv);
        K33_shape_inv = gather(K33_shape_inv);
        K_update = gather(K_update);
    end
    
    
    for qx = 1:Ny
        for qy = 1:Nx
            for qz = 1:Nz
                % only update K and K_inv, for nodes that lost bonds in previous step
                if K_update (qx,qy,qz)
                    % K is symmetric
                    K_shape =[K11_shape(qx,qy,qz) K12_shape(qx,qy,qz) K13_shape(qx,qy,qz);...
                        K12_shape(qx,qy,qz) K22_shape(qx,qy,qz) K23_shape(qx,qy,qz);...
                        K13_shape(qx,qy,qz) K23_shape(qx,qy,qz) K33_shape(qx,qy,qz)];
                    if (det(K_shape)<= 0)
                        K_shape = eye(3);
                    end
                    K_shape_inv = chiB(qx,qy,qz)*(K_shape\eye(3));
                    K11_shape_inv (qx,qy,qz) = K_shape_inv(1,1);
                    K12_shape_inv (qx,qy,qz) = K_shape_inv(1,2);
                    K13_shape_inv (qx,qy,qz) = K_shape_inv(1,3);
                    K21_shape_inv (qx,qy,qz) = K_shape_inv(2,1);
                    K22_shape_inv (qx,qy,qz) = K_shape_inv(2,2);
                    K23_shape_inv (qx,qy,qz) = K_shape_inv(2,3);
                    K31_shape_inv (qx,qy,qz) = K_shape_inv(3,1);
                    K32_shape_inv (qx,qy,qz) = K_shape_inv(3,2);
                    K33_shape_inv (qx,qy,qz) = K_shape_inv(3,3);

                end
            end
        end
    end
    if run_in_gpu ==1
        %make gpuarray
        K11_shape_inv = gpuArray(K11_shape_inv);
        K12_shape_inv = gpuArray(K12_shape_inv);
        K13_shape_inv = gpuArray(K13_shape_inv);
        K21_shape_inv = gpuArray(K21_shape_inv);
        K22_shape_inv = gpuArray(K22_shape_inv);
        K23_shape_inv = gpuArray(K23_shape_inv);
        K31_shape_inv = gpuArray(K31_shape_inv);
        K32_shape_inv = gpuArray(K32_shape_inv);
        K33_shape_inv = gpuArray(K33_shape_inv);
    end
    
    % store K_inv for next time step:
    history_var.K_inv11 = K11_shape_inv;
    history_var.K_inv12 = K12_shape_inv; 
    history_var.K_inv13 = K13_shape_inv;
    history_var.K_inv21 = K21_shape_inv;
    history_var.K_inv22 = K22_shape_inv; 
    history_var.K_inv23 = K23_shape_inv;
    history_var.K_inv31 = K31_shape_inv;
    history_var.K_inv32 = K32_shape_inv;
    history_var.K_inv33 = K33_shape_inv; 
     
    % compute derormation gradient (Fij)
    
    F11 = 1 +  chiB_lambda.*((-ifftn(chiB_lambda_u1_hat.* A1s_hat,'symmetric') + ...
        u1.*chiB_lambda_A1s_hat_invfft).* K11_shape_inv + ...
        (-ifftn(chiB_lambda_u1_hat.* A2s_hat,'symmetric') + ...
        u1.*chiB_lambda_A2s_hat_invfft).* K21_shape_inv +...
        (-ifftn(chiB_lambda_u1_hat.* A3s_hat,'symmetric') + ...
        u1.*chiB_lambda_A3s_hat_invfft).* K31_shape_inv)*dv;
    
    F12 = chiB_lambda.*((-ifftn(chiB_lambda_u1_hat.* A1s_hat,'symmetric') + ...
        u1.*chiB_lambda_A1s_hat_invfft).* K12_shape_inv +...
        (-ifftn(chiB_lambda_u1_hat.* A2s_hat,'symmetric') + ...
        u1.*chiB_lambda_A2s_hat_invfft).* K22_shape_inv +...
        (-ifftn(chiB_lambda_u1_hat.* A3s_hat,'symmetric') + ...
        u1.*chiB_lambda_A3s_hat_invfft).* K32_shape_inv)*dv;
    
    F13 = chiB_lambda.*((-ifftn(chiB_lambda_u1_hat.* A1s_hat,'symmetric') + ...
        u1.*chiB_lambda_A1s_hat_invfft).* K13_shape_inv +...
        (-ifftn(chiB_lambda_u1_hat.* A2s_hat,'symmetric') + ...
        u1.*chiB_lambda_A2s_hat_invfft).* K23_shape_inv +...
        (-ifftn(chiB_lambda_u1_hat.* A3s_hat,'symmetric') + ...
        u1.*chiB_lambda_A3s_hat_invfft).* K33_shape_inv)*dv;
    
    F21 = chiB_lambda.*((-ifftn(chiB_lambda_u2_hat.* A1s_hat,'symmetric') + ...
        u2.*ifftn(A1s_hat.*chiB_lambda_hat,'symmetric')).* K11_shape_inv + ...
        (-ifftn(chiB_lambda_u2_hat.* A2s_hat,'symmetric') + ...
        u2.*ifftn(A2s_hat.*chiB_lambda_hat,'symmetric')).* K21_shape_inv + ...
        (-ifftn(chiB_lambda_u2_hat.* A3s_hat,'symmetric') + ...
        u2.*ifftn(A3s_hat.*chiB_lambda_hat,'symmetric')).* K31_shape_inv)*dv;
    
    F22 = 1 + chiB_lambda.*((-ifftn(chiB_lambda_u2_hat.* A1s_hat,'symmetric') + ...
        u2.*chiB_lambda_A1s_hat_invfft).* K12_shape_inv +...
        (-ifftn(chiB_lambda_u2_hat.* A2s_hat,'symmetric') + ...
        u2.*chiB_lambda_A2s_hat_invfft).* K22_shape_inv+...
        (-ifftn(chiB_lambda_u2_hat.* A3s_hat,'symmetric') + ...
        u2.*chiB_lambda_A3s_hat_invfft).* K32_shape_inv )*dv;
    
    
    F23 = chiB_lambda.*((-ifftn(chiB_lambda_u2_hat.* A1s_hat,'symmetric') + ...
        u2.*chiB_lambda_A1s_hat_invfft).* K13_shape_inv+...
        (-ifftn(chiB_lambda_u2_hat.* A2s_hat,'symmetric') + ...
        u2.*chiB_lambda_A2s_hat_invfft).* K23_shape_inv +...
        (-ifftn(chiB_lambda_u2_hat.* A3s_hat,'symmetric') + ...
        u2.*chiB_lambda_A3s_hat_invfft).* K33_shape_inv)*dv;
    
    
    F31 = chiB_lambda.*((-ifftn(chiB_lambda_u3_hat.* A1s_hat,'symmetric') + ...
        u3.*chiB_lambda_A1s_hat_invfft).* K11_shape_inv + ...
        (-ifftn(chiB_lambda_u3_hat.* A2s_hat,'symmetric') + ...
        u3.*chiB_lambda_A2s_hat_invfft).* K21_shape_inv + ...
        (-ifftn(chiB_lambda_u3_hat.* A3s_hat,'symmetric') + ...
        u3.*chiB_lambda_A3s_hat_invfft).* K31_shape_inv)*dv;
    
    
    F32 = chiB_lambda.*((-ifftn(chiB_lambda_u3_hat.* A1s_hat,'symmetric') + ...
        u3.*chiB_lambda_A1s_hat_invfft).* K12_shape_inv + ...
        (-ifftn(chiB_lambda_u3_hat.* A2s_hat,'symmetric') + ...
        u3.*chiB_lambda_A2s_hat_invfft).* K22_shape_inv +...
        (-ifftn(chiB_lambda_u3_hat.* A3s_hat,'symmetric') + ...
        u3.*chiB_lambda_A3s_hat_invfft).* K32_shape_inv)*dv;
    
    
    F33 = 1+ chiB_lambda.*((-ifftn(chiB_lambda_u3_hat.* A1s_hat,'symmetric') + ...
        u3.*chiB_lambda_A1s_hat_invfft).* K13_shape_inv +...
        (-ifftn(chiB_lambda_u3_hat.* A2s_hat,'symmetric') + ...
        u3.*chiB_lambda_A2s_hat_invfft).* K23_shape_inv +...
        (-ifftn(chiB_lambda_u3_hat.* A3s_hat,'symmetric') + ...
        u3.*chiB_lambda_A3s_hat_invfft).* K33_shape_inv)*dv;
    
    % compute Green strain tensor
    green_strain11 = 0.5.*(F11.*F11 + F21.*F21 + F31.*F31 - 1);
    green_strain12 = 0.5.*(F11.*F12 + F21.*F22 + F31.*F32 - 0);
    green_strain13 = 0.5.*(F11.*F13 + F21.*F23 + F31.*F33 - 0);
    green_strain21 = green_strain12;
    green_strain22 = 0.5.*(F12.*F12 + F22.*F22 + F32.*F32 - 1);
    green_strain23 = 0.5.*(F12.*F13 + F22.*F23 + F32.*F33 - 0);
    green_strain31 = green_strain13;
    green_strain32 = green_strain23 ;
    green_strain33 = 0.5.*(F13.*F13 + F23.*F23 + F33.*F33 - 1);
        
    % compute second Piola-Kirchhoff stress tensor, Saint Venant-Kirchhoff model
    elast_const =  K - 2*G/3;
    sPK11 = 2*G.*green_strain11 + elast_const.*(green_strain11 + green_strain22 + green_strain33) ;
    sPK12 = 2*G.*green_strain12  ;
    sPK13 = 2*G.*green_strain13  ;
    sPK21 = sPK12 ;
    sPK22 = 2*G.*green_strain22 + elast_const.*(green_strain11 +green_strain22 + green_strain33) ;
    sPK23 = 2*G.*green_strain23  ;
    sPK31 = sPK13  ;
    sPK32 = sPK23  ;
    sPK33 = 2*G.*green_strain33 + elast_const.*(green_strain11 + green_strain22 + green_strain33) ;
    
    % compute first Piola-Kirchhoff stress tensor form seecond
    % Piola-Kirchhoff PK = F.sPK
    PK11 = F11.*sPK11 + F12.*sPK21 +F13.*sPK31;
    PK12 = F11.*sPK12 + F12.*sPK22 +F13.*sPK32;
    PK13 = F11.*sPK13 + F12.*sPK23 +F13.*sPK33;
    
    PK21 = F21.*sPK11 + F22.*sPK21 +F23.*sPK31;
    PK22 = F21.*sPK12 + F22.*sPK22 +F23.*sPK32;
    PK23 = F21.*sPK13 + F22.*sPK23 +F23.*sPK33;
    
    PK31 = F31.*sPK11 + F32.*sPK21 +F33.*sPK31;
    PK32 = F31.*sPK12 + F32.*sPK22 +F33.*sPK32;
    PK33 = F31.*sPK13 + F32.*sPK23 +F33.*sPK33;
    
    % compute internal force density (Li)
    L1 = compute_Li(PK11,PK12,PK13, K11_shape_inv, K12_shape_inv, K13_shape_inv, K21_shape_inv,...
        K22_shape_inv, K23_shape_inv,K31_shape_inv,K32_shape_inv,K33_shape_inv,...
        A1s_hat, A2s_hat, A3s_hat, chiB_lambda,chiB_lambda_u1_hat,omega0s_hat,...
        chiB_lambda_hat,F11,F12,F13,A1s_hat,beta_stab,u1,dv, chiB_lambda_A1s_hat_invfft,...
        chiB_lambda_A2s_hat_invfft,chiB_lambda_A3s_hat_invfft);
    
    L2 = compute_Li(PK21,PK22,PK23, K11_shape_inv, K12_shape_inv, K13_shape_inv, K21_shape_inv,...
        K22_shape_inv, K23_shape_inv,K31_shape_inv,K32_shape_inv,K33_shape_inv,...
        A1s_hat, A2s_hat, A3s_hat,  chiB_lambda,chiB_lambda_u2_hat,omega0s_hat,...
        chiB_lambda_hat,F21,F22,F23,A2s_hat,beta_stab,u2,dv, chiB_lambda_A1s_hat_invfft,...
        chiB_lambda_A2s_hat_invfft,chiB_lambda_A3s_hat_invfft);
    
    L3 = compute_Li(PK31,PK32,PK33, K11_shape_inv, K12_shape_inv, K13_shape_inv, K21_shape_inv,...
        K22_shape_inv, K23_shape_inv,K31_shape_inv,K32_shape_inv,K33_shape_inv,...
        A1s_hat, A2s_hat, A3s_hat, chiB_lambda,chiB_lambda_u3_hat,omega0s_hat,...
        chiB_lambda_hat,F31,F32,F33,A3s_hat,beta_stab,u3,dv, chiB_lambda_A1s_hat_invfft,...
        chiB_lambda_A2s_hat_invfft,chiB_lambda_A3s_hat_invfft);
    
    %%% strain enegry density (W)
    % compute W
    W = 0.5*(sPK11.*green_strain11 + sPK12.*green_strain12 + sPK13.*green_strain13 +...
        sPK21.*green_strain21 + sPK22.*green_strain22 + sPK23.*green_strain23 + sPK31.*green_strain31 +...
        sPK32.*green_strain32 + sPK33.*green_strain33);
    
    %%% update lambda according to the damage model
    G0 = props(3);
    
    lambda( W >= G0/(2*delta) ) = 0;
    history_var.lambda = lambda;
    
    %%% update damage index
    
    chiB_hat = fftn(chiB);
    numerator = chiB_lambda.*ifftn(chiB_lambda_hat.*omega0s_hat);
    denominator = chiB.*ifftn(chiB_hat.*omega0s_hat);
    denominator(denominator == 0) = 1; %avoid division by zero
    
    damage_old = history_var.damage;
    damage = 1 - numerator./denominator;
    %logical varibale to lable nodes that need to have their K updated
    history_var.K_update = (abs(damage - damage_old) > 1e-6);
    history_var.damage = damage;
    
end

end



function Li = compute_Li(PK1,PK2,PK3, K11_shape_inv, K12_shape_inv, K13_shape_inv, K21_shape_inv,...
    K22_shape_inv, K23_shape_inv,K31_shape_inv,K32_shape_inv,K33_shape_inv,...
    A1s_hat, A2s_hat, A3s_hat, chiB_lambda,chiB_lambda_u_hat,omega0s_hat,...
    chiB_lambda_hat,F1,F2,F3,As_hat,beta_stab,u,dv, chiB_lambda_A1s_hat_invfft,...
    chiB_lambda_A2s_hat_invfft,chiB_lambda_A3s_hat_invfft)

% This function computes internal force density in i-direction for 
% PD-correspondence materials

% Li1 to Li6 are main components of the force density:
Li1=(PK1.*((K11_shape_inv.*chiB_lambda_A1s_hat_invfft)+...
    (K12_shape_inv.*chiB_lambda_A2s_hat_invfft) +...
    (K13_shape_inv.*chiB_lambda_A3s_hat_invfft)));

Li2 = (PK2.*((K21_shape_inv.*chiB_lambda_A1s_hat_invfft)+...
    (K22_shape_inv.*chiB_lambda_A2s_hat_invfft) + ...
    (K23_shape_inv.*chiB_lambda_A3s_hat_invfft)));

Li3 = (PK3.*((K31_shape_inv.*chiB_lambda_A1s_hat_invfft)+...
    (K32_shape_inv.*chiB_lambda_A2s_hat_invfft) +...
    (K33_shape_inv.*chiB_lambda_A3s_hat_invfft)));

Li4 = ifftn(fftn(chiB_lambda.*(PK1.*...
    K11_shape_inv +PK2 .*K21_shape_inv + PK3.*K31_shape_inv))...
    .*A1s_hat,'symmetric');

Li5 = ifftn(fftn(chiB_lambda.*(PK1.*...
    K12_shape_inv +PK2 .*K22_shape_inv + PK3.*K32_shape_inv))...
    .*A2s_hat,'symmetric');

Li6 = ifftn(fftn(chiB_lambda.*(PK1.*...
    K13_shape_inv +PK2 .*K23_shape_inv + PK3.*K33_shape_inv))...
    .*A3s_hat,'symmetric');

% Li7 to Li9 are components of the stabilizer term
Li7 = -2*ifftn(chiB_lambda_hat.* As_hat,'symmetric')...
    -2*u.*ifftn(chiB_lambda_hat.*omega0s_hat,'symmetric') + ...
    2*ifftn(chiB_lambda_u_hat.*omega0s_hat,'symmetric');
Li8 = F1 .*ifftn(chiB_lambda_hat .* A1s_hat,'symmetric') + F2.*...
    ifftn(chiB_lambda_hat .* A2s_hat,'symmetric') + F3.*...
    ifftn(chiB_lambda_hat .* A3s_hat,'symmetric');
Li9 = ifftn(fftn(chiB_lambda.*F1).*A1s_hat, 'symmetric') +...
    ifftn(fftn(chiB_lambda.*F2).*A2s_hat, 'symmetric') +...
    ifftn(fftn(chiB_lambda.*F3).*A3s_hat, 'symmetric');
% assemble all components to find force density in i-direction (Li)
Li = (-chiB_lambda.*(Li1 + Li2 + Li3 + Li4 + Li5 +Li6)+...
    chiB_lambda.*beta_stab.*(Li7 +Li8+ Li9))*dv;
end

