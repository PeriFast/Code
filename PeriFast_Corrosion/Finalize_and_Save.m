if (is_plot_in_Matlab)
    close(writerObj);
end
if (is_output_to_Tecplot)
    mat2tecplot(tdata,'multipit_3D_test_coarse.plt')
end
