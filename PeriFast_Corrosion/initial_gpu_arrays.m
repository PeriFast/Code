delta = gpuArray(delta);
X = gpuArray(X);Y = gpuArray(Y);Z = gpuArray(Z);
Nx = gpuArray(Nx); Ny = gpuArray(Ny); Nz = gpuArray(Nz);
Lx_T = gpuArray(Lx_T); Ly_T = gpuArray(Ly_T); Lz_T = gpuArray(Lz_T);

muS_diff_hat = gpuArray(muS_diff_hat); muS_corr_hat = gpuArray(muS_corr_hat);

n1 = gpuArray(n1); n2 = gpuArray(n2); n3 = gpuArray(n3); n4 = gpuArray(n4);
n5 = gpuArray(n5); n6 = gpuArray(n6);
BCa_type = gpuArray(BCa_type); BCa_value = gpuArray(BCa_value);
BCb_type = gpuArray(BCb_type); BCb_value = gpuArray(BCb_value);
BCc_type = gpuArray(BCc_type); BCc_value = gpuArray(BCc_value);
BCd_type = gpuArray(BCd_type); BCd_value = gpuArray(BCd_value);
BCe_type = gpuArray(BCe_type); BCe_value = gpuArray(BCe_value);
BCf_type = gpuArray(BCf_type); BCf_value = gpuArray(BCf_value);

C = gpuArray(C); C_w = gpuArray(C_w); C_sat = gpuArray(C_sat); 
chi = gpuArray(chi); chi_l = gpuArray(chi_l); chi_N = gpuArray(chi_N);
chi_s = gpuArray(chi_s); chi_l_pit = gpuArray(chi_l_pit); chi_salt = gpuArray(chi_salt); 