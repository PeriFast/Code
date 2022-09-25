% create videos from output data
num_of_outputs = size(outputs_var_for_visualization,2);

for i = 1:num_of_outputs
    out_var = outputs_var_for_visualization(1,i);

    if out_var  == 1
        frame = getframe(figure(i));
        writeVideo(u1_video,frame);
    end
    if out_var  == 2
        frame = getframe(figure(i));
        writeVideo(u2_video,frame);
    end
    if out_var  == 3
        frame = getframe(figure(i));
        writeVideo(u3_video,frame);
    end
    if out_var  == 4
        frame = getframe(figure(i));
        writeVideo(u_mag_video,frame);
    end
    if out_var  == 5
        frame = getframe(figure(i));
        writeVideo(v1_video,frame);
    end
    if out_var  == 6
        frame = getframe(figure(i));
        writeVideo(v2_video,frame);

    end
    if out_var  == 7
        frame = getframe(figure(i));
        writeVideo(v3_video,frame);
    end

    if out_var  == 8
        frame = getframe(figure(i));
        writeVideo(v_mag_video,frame);
    end
    if out_var  == 9
        frame = getframe(figure(i));
        writeVideo(W_video,frame);
    end
    if out_var  == 10
        frame = getframe(figure(i));
        writeVideo(d_video,frame);

    end
    if out_var  == 11
        frame = getframe(figure(i));
        writeVideo(lambda_video,frame);
    end


end