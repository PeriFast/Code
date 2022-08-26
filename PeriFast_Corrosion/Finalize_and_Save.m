if (is_plot_in_Matlab)
    close(writerObj);
end
if (is_output_to_Tecplot)
    mat2tecplot(tdata,'UNL_N_pitting_corrosion.plt')
end
fprintf('...saving results to file...\n');
save('Results.mat','Output','X','Y','Z','t','C','-v7.3')