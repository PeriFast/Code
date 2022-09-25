% close  videos 
num_of_outputs = size(outputs_var_for_visualization,2);

for i = 1:num_of_outputs
    out_var = outputs_var_for_visualization(1,i);

    if out_var  == 1
        
        close(u1_video);
    end
    if out_var  == 2
        
         close(u2_video);
    end
    if out_var  == 3
       
         close(u3_video);
    end
    if out_var  == 4
        
         close(u_mag_video);
    end
    if out_var  == 5
        
         close(v1_video);
    end
    if out_var  == 6
        
         close(v2_video);

    end
    if out_var  == 7
       
         close(v3_video);
    end

    if out_var  == 8
       
         close(v_mag_video);
    end
    if out_var  == 9
        
         close(W_video);

    end
    if out_var  == 10
        
         close(d_video);

    end
    if out_var  == 11
        
         close(lambda_video);
    end


end
