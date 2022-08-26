%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function contains the time-invariant components of the PD constitutive
% models 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function constit_invar = pre_constitutive(props,delta,X,Y,Z,Box_T)

mat_type = props(1);

%%% Get box coordinates
x_min_T = Box_T.xmin; Lx_T = Box_T.Lx;
y_min_T = Box_T.ymin; Ly_T = Box_T.Ly;
z_min_T = Box_T.zmin; Lz_T = Box_T.Lz;

x_c = x_min_T + Lx_T/2;
y_c = y_min_T + Ly_T/2;
z_c = z_min_T + Lz_T/2;

if mat_type == 0 % linearized bond-based micro-elastic solid
    
    E = props(4);% Young modulus
    const = 12*E/(pi*delta^4);% material constant (micromodulus)
    
    % define omega0 which is one in horizon and zero elsewhere
     omega0 = @(X,Y,Z) (sqrt(X.^2 + Y.^2 + Z.^2) <= delta);

    % adjust kernel functions on the periodic box T
    omega0s = fftshift(omega0(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.omega0s_hat = fftn(omega0s);
        
    % define elements of tensor-state C:
    C11 = @(X,Y,Z) (const*X.*X./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    C12 = @(X,Y,Z) (const*X.*Y./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    C13 = @(X,Y,Z) (const*X.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    C22 = @(X,Y,Z) (const*Y.*Y./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    C23 = @(X,Y,Z) (const*Y.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    C33 = @(X,Y,Z) (const*Z.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)).^(3/2)).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta);
    
    % adjust kernel functions on the periodic box T
    C11s = fftshift(C11(X - x_c, Y - y_c, Z - z_c));
    C12s = fftshift(C12(X - x_c, Y - y_c, Z - z_c));
    C13s = fftshift(C13(X - x_c, Y - y_c, Z - z_c));
    C22s = fftshift(C22(X - x_c, Y - y_c, Z - z_c));
    C23s = fftshift(C23(X - x_c, Y - y_c, Z - z_c));
    C33s = fftshift(C33(X - x_c, Y - y_c, Z - z_c));
    

    % compute DFT
    constit_invar.C11s_hat = fftn(C11s); constit_invar.C12s_hat = fftn(C12s);
    constit_invar.C13s_hat = fftn(C13s); constit_invar.C22s_hat = fftn(C22s);
    constit_invar.C23s_hat = fftn(C23s); constit_invar.C33s_hat = fftn(C33s);
    % C21,C31, and C32 are not needed due to symmetry
    
    
end

if mat_type == 1 % linearized state-based
    E = props(4);% Young modulus
    nu = props (5);% Poisson ratio
    G = E/(2*(1 + nu)); % shear modulus
    
    const = 30*G;% material constant
    %%% define omega0 which is the influnece function
    omega0 = @(X,Y,Z)(1./sqrt(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)))...
        .*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta & X.^2 + Y.^2 + Z.^2 ~= 0);

    % adjust kernel functions on the periodic box T
    omega0s = fftshift(omega0(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.omega0s_hat = fftn(omega0s);
    % weighted volume (m)
    m_kernel = @(X,Y,Z) omega0(X,Y,Z).*(X.^2 + Y.^2 + Z.^2);
    % adjust weighted volume function on the periodic box T and compute DFT
    m_kernels = fftshift(m_kernel(X - x_c, Y - y_c, Z - z_c));
    constit_invar.m_kernels_hat = fftn(m_kernels);
    
    %%% define vector-state A:

    A1 =  @(X,Y,Z) omega0(X,Y,Z) .* X;
    A2 =  @(X,Y,Z) omega0(X,Y,Z) .* Y;
    A3 =  @(X,Y,Z) omega0(X,Y,Z) .* Z;
    % adjust kernel functions on the periodic box T
    A1s = fftshift(A1(X - x_c, Y - y_c, Z - z_c));
    A2s = fftshift(A2(X - x_c, Y - y_c, Z - z_c));
    A3s = fftshift(A3(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.A1s_hat = fftn(A1s); constit_invar.A2s_hat = fftn(A2s); constit_invar.A3s_hat = fftn(A3s);
    
    %%% define tensor-state C:
    % functions
    C11 = @(X,Y,Z) (const*omega0(X,Y,Z).*X.*X./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    C12 = @(X,Y,Z) (const*omega0(X,Y,Z).*X.*Y./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    C13 = @(X,Y,Z) (const*omega0(X,Y,Z).*X.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    C22 = @(X,Y,Z) (const*omega0(X,Y,Z).*Y.*Y./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    C23 = @(X,Y,Z) (const*omega0(X,Y,Z).*Y.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    C33 = @(X,Y,Z) (const*omega0(X,Y,Z).*Z.*Z./(X.^2 + Y.^2 + Z.^2 + (X.^2 + Y.^2 + Z.^2 == 0)));
    
    % adjust kernel functions on the periodic box T
    C11s = fftshift(C11(X - x_c, Y - y_c, Z - z_c));
    C12s = fftshift(C12(X - x_c, Y - y_c, Z - z_c));
    C13s = fftshift(C13(X - x_c, Y - y_c, Z - z_c));
    C22s = fftshift(C22(X - x_c, Y - y_c, Z - z_c));
    C23s = fftshift(C23(X - x_c, Y - y_c, Z - z_c));
    C33s = fftshift(C33(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.C11s_hat = fftn(C11s); constit_invar.C12s_hat = fftn(C12s);
    constit_invar.C13s_hat = fftn(C13s); constit_invar.C22s_hat = fftn(C22s);
    constit_invar.C23s_hat = fftn(C23s); constit_invar.C33s_hat = fftn(C33s);
    % C21,C31, and C32 are not needed due to symmetry

end

if mat_type == 2 % PD-corresspondence model

    %%% define omega0 which is the influence function for this material
    omega0 = @(X,Y,Z)(1).*(sqrt(X.^2 + Y.^2 + Z.^2) <= delta & X.^2 + Y.^2 + Z.^2 ~= 0);
    % adjust kernel functions on the periodic box T
    omega0s = fftshift(omega0(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.omega0s_hat = fftn(omega0s);
        
    %%% define vector-state A:
    A1 =  @(X,Y,Z) omega0(X,Y,Z) .* X;
    A2 =  @(X,Y,Z) omega0(X,Y,Z) .* Y;
    A3 =  @(X,Y,Z) omega0(X,Y,Z) .* Z;
    
    % adjust kernel functions on the periodic box T
    A1s = fftshift(A1(X - x_c, Y - y_c, Z - z_c));
    A2s = fftshift(A2(X - x_c, Y - y_c, Z - z_c));
    A3s = fftshift(A3(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.A1s_hat = fftn(A1s); constit_invar.A2s_hat = fftn(A2s); constit_invar.A3s_hat = fftn(A3s);
    
    %%% define tensor-state C:
    C11 = @(X,Y,Z) (omega0(X,Y,Z).*X.*X);
    C12 = @(X,Y,Z) (omega0(X,Y,Z).*X.*Y);
    C13 = @(X,Y,Z) (omega0(X,Y,Z).*X.*Z);
    C22 = @(X,Y,Z) (omega0(X,Y,Z).*Y.*Y);
    C23 = @(X,Y,Z) (omega0(X,Y,Z).*Y.*Z);
    C33 = @(X,Y,Z) (omega0(X,Y,Z).*Z.*Z);
    
    % adjust kernel functions on the periodic box T
    C11s = fftshift(C11(X - x_c, Y - y_c, Z - z_c));
    C12s = fftshift(C12(X - x_c, Y - y_c, Z - z_c));
    C13s = fftshift(C13(X - x_c, Y - y_c, Z - z_c));
    C22s = fftshift(C22(X - x_c, Y - y_c, Z - z_c));
    C23s = fftshift(C23(X - x_c, Y - y_c, Z - z_c));
    C33s = fftshift(C33(X - x_c, Y - y_c, Z - z_c));
    % compute DFT
    constit_invar.C11s_hat = fftn(C11s); constit_invar.C12s_hat = fftn(C12s);
    constit_invar.C13s_hat = fftn(C13s); constit_invar.C22s_hat = fftn(C22s);
    constit_invar.C23s_hat = fftn(C23s); constit_invar.C33s_hat = fftn(C33s);
    % C21,C31, and C32 are not needed due to symmetry

end

end




