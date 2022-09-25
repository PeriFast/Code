%user can use this script to postprocess the stored matlab data
load('Results.mat');
output_size = size(Output,2);
    open_Matlab_video;
    No_snapshots = output_size;
    for ks = 1:output_size
        if (mod(ks,round(snap_frame/snap))==0 || ks == output_size)
        visualization;
        end
    end
    close_Matlab_video