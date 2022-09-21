function create_Matlab_video(damage_video)
% create videos from output data
% create video of damage map from snapshots
         frame = getframe(figure(1));
         writeVideo(damage_video,frame);

 % user can create videos from other outputs as well
         
%          frame = getframe(figure(2));
%          writeVideo(vel1_video,frame);
%          
%          
%          frame = getframe(figure(3));
%          writeVideo(vel2_video,frame);
% 
%          frame = getframe(figure(4));
%          writeVideo(energy_video,frame);
end
         