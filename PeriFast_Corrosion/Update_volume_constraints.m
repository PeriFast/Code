% Update volume constraints w(x,t) according to the given local boundary conditions:
if(BCa_type == 1)
    w(:,:,Nz - size(n1,1) + 1:Nz) = 2*BCa_value - C0(:,:,n1(end):-1:n1(1)); %BC(a)
else
    w(:,:,Nz - size(n1,1) + 1:Nz) = 2*BCa_value*(Z(:,:,Nz - size(n1,1) + 1:Nz)...
        -(Lz/2 - delta)) + C(:,:,n1(end):-1:n1(1)); %Neu
end

if(BCb_type == 1)
    w(:,:,1:size(n2,1)) = 2*BCb_value - C0(:,:,n2(end):-1:n2(1)); %BC(b)
else
    w(:,:,1:size(n2,1)) = -2*BCb_valueN*((-Lz/2 + delta) - Z(:,:,1:size(n2,1)))...
        + C(:,:,n2(end):-1:n2(1)); %Neu
end

if(BCc_type == 1)
    w(:, Nx - size(n3,2)+1:Nx,:) = 2*BCc_value - C0(:,n3(end):-1:n3(1),:); %BC(c)
else
    w(:, Nx - size(n3,2)+1:Nx,:) = 2*BCc_valueN*(X(:, Nx - size(n3,2) + 1:...
        Nx,:) - (Lx/2-delta)) + C(:,n3(end):-1:n3(1),:);
end

if(BCd_type == 1)
    w(:,1:size(n4,2),:) = 2*BCd_value - C0(:,n4(end):-1:n4(1),:); %BC(d)
else
    w(:,1:size(n4,2),:) = -2*BCd_valueN*((-Lx/2 + delta) - X(:,1:size(n4,2),...
        :)) + C(:,n4(end):-1:n4(1),:);
end

if(BCe_type == 1)
    w(Ny - size(n5,1) + 1:Ny,:,:) = 2*BCe_value - C0(n5(end):-1:n5(1),:,:); %BC(e)
else
    w(Ny - size(n5,1) + 1:Ny,:,:) = 2*BCe_valueN*(Y(Ny - size(n5,1) + 1:Ny,...
        :,:) -(Ly/2 - delta)) + C(n5(end):-1:n5(1),:,:);
end

if(BCf_type == 1)
    w(1:size(n6,1),:,:) = 2*BCf_value - C0(n6(end):-1:n6(1),:,:); %BC(f)
else
    w(1:size(n6,1),:,:) = -2*BCf_valueN*((-Ly/2 + delta) - Y(1:size(n6,1),...
        :,:)) + C(n6(end):-1:n6(1),:,:);
end
