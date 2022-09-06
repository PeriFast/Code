function [Output,j] = dump_output(Output,j,C,chi_l,t,run_in_gpu)

% user can add any desired quantity to the "Output" varibale
if(run_in_gpu == 1)
    Output(j).C = gather(C);
    Output(j).chi_l = gather(chi_l);
    Output(j).t = t;
else
    Output(j).C = C;
    Output(j).chi_l = chi_l;
    Output(j).t = t;
end
end