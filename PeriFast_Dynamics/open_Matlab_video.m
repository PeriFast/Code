% open  videos 
num_of_outputs = size(outputs_var_for_visualization,2);

for i = 1:num_of_outputs
    out_var = outputs_var_for_visualization(1,i);
    outFilename = sprintf('out%d.mp4', i);
    if out_var  == 1
        u1_video = VideoWriter(outFilename,'MPEG-4');
        open(u1_video);
    end
    if out_var  == 2
        u2_video = VideoWriter(outFilename,'MPEG-4');
        open(u2_video);
    end
    if out_var  == 3
        u3_video = VideoWriter(outFilename,'MPEG-4');
        open(u3_video);
    end
    if out_var  == 4
        u_mag_video = VideoWriter(outFilename,'MPEG-4');
        open(u_mag_video);
    end
    if out_var  == 5
        v1_video = VideoWriter(outFilename,'MPEG-4');
        open(v1_video);
    end
    if out_var  == 6
        v2_video = VideoWriter(outFilename,'MPEG-4');
        open(v2_video);

    end
    if out_var  == 7
        v3_video = VideoWriter(outFilename,'MPEG-4');
        open(v3_video);
    end

    if out_var  == 8
        v_mag = VideoWriter(outFilename,'MPEG-4');
        open(v_mag);
    end
    if out_var  == 9
        W_video = VideoWriter(outFilename,'MPEG-4');
        open(W_video);

    end
    if out_var  == 10
        d_video = VideoWriter(outFilename,'MPEG-4');
        open(d_video);

    end
    if out_var  == 11
        lambda_video = VideoWriter(outFilename,'MPEG-4');
        open(lambda_video);
    end


end
