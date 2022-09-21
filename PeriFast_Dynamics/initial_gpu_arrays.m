%make gpuarrays in order to run on gpu
mat_type = props(1);
chiB = gpuArray(chiB);
chiOx = gpuArray(chiOx);
chiOy = gpuArray(chiOy);
chiOz = gpuArray(chiOz);
chi_predam = gpuArray(chi_predam);
lambda0 = gpuArray(lambda0);
u1 = gpuArray(u1); u2= gpuArray(u2); u3 = gpuArray(u3);
history_var.lambda = gpuArray(history_var.lambda);
if (mat_type ==1 || mat_type ==2)
constit_invar.A1s_hat = gpuArray(constit_invar.A1s_hat);
constit_invar.A2s_hat = gpuArray(constit_invar.A2s_hat);
constit_invar.A3s_hat = gpuArray(constit_invar.A3s_hat);
end
constit_invar.C11s_hat = gpuArray(constit_invar.C11s_hat);
constit_invar.C12s_hat = gpuArray(constit_invar.C12s_hat);
constit_invar.C13s_hat = gpuArray(constit_invar.C13s_hat);
constit_invar.C22s_hat = gpuArray(constit_invar.C22s_hat);
constit_invar.C23s_hat = gpuArray(constit_invar.C23s_hat);
constit_invar.C33s_hat = gpuArray(constit_invar.C33s_hat);
constit_invar.omega0s_hat = gpuArray(constit_invar.omega0s_hat);
if (mat_type ==1)
constit_invar.m_kernels_hat = gpuArray(constit_invar.m_kernels_hat);
end
L1 = gpuArray (L1); L2 = gpuArray (L2); L3 = gpuArray (L3);