function animate_driving(subj, trial, steering, gaze, starts, trial_roads, roads, movie_filename)

if nargin < 8
    movie_filename = '';
    make_movie = false;
else
    movObj = VideoWriter(movie_filename);
    make_movie = true;
end;

steering_t = squeeze(steering(subj,trial,:,1));
h = mean(diff(steering_t));

if make_movie
    movObj.FrameRate = ceil(1/h);
end;

gaze_t = (squeeze(gaze(subj,trial,:,1))-starts(subj,trial))/1000;
gaze_h = mean(diff(gaze_t));

% road x
[t, pos_x] =  makeuniform(steering_t, squeeze(steering(subj,trial,:,6)), h);
% road z
[~, pos_z] = makeuniform(steering_t, squeeze(steering(subj,trial,:,7)), h);
% heading
[~, heading] = makeuniform(steering_t, squeeze(steering(subj,trial,:,5)), h);


% gaze position -- massive downsampling here
%gaze_x = resample(squeeze(gaze(subj,trial,:,2)), ceil(1/h), ceil(1/gaze_h));
%[gaze_t_ds,gaze_x] = makeuniform(gaze_t, squeeze(gaze(subj,trial,:,2)), h);
%[~,gaze_y] = makeuniform(gaze_t, squeeze(gaze(subj,trial,:,3)), h);

gaze_x = squeeze(gaze(subj,trial,:,2)); 
gaze_y = squeeze(gaze(subj,trial,:,3)); 

% we are only interested in gaze locations on the screen
g_screen = gaze_x > 0 & gaze_x <= 1024 & gaze_y > 0 & gaze_y < 384;

gaze_x_ds = interp_over_time(t,gaze_t(g_screen), gaze_x(g_screen));
gaze_y_ds = interp_over_time(t,gaze_t(g_screen), gaze_y(g_screen));

[gaze_xprime, gaze_z] = inverse_perspective(gaze_x_ds,gaze_y_ds);

road(:,1) = roads(trial_roads(subj,trial),1:4000,2);
road(:,2) = roads(trial_roads(subj,trial),4001:8000,2);
road_z = (1:4000)/4;

figure;

if make_movie
    open(movObj);
    set(gca,'nextplot','replacechildren');
end;

% heading vectors
for i=1:length(pos_z)
    % road
    plot(road_z,(road-50)/5,'k','linewidth',3);
    hold on;
    plot(-pos_z(i), -pos_x(i),'o','markersize', 10);
    th=heading(i);
    R = [cos(th) -sin(th);sin(th) cos(th)];
    gaze_vec = R*[gaze_z(i) gaze_xprime(i)]';
    plot([-pos_z(i) -pos_z(i) + 4*cos(th)],[-pos_x(i) -pos_x(i) + 4*sin(th)],'r','linewidth',3);
    plot([-pos_z(i) -pos_z(i) + gaze_vec(1)], [-pos_x(i) -pos_x(i) + gaze_vec(2)],'m','linewidth',3);
    hold off;
    axis([-pos_z(i)-10 -pos_z(i)+30 -20 20]);
    pause(h);
    if make_movie
        F = getframe;
        if any( size(F.cdata) > [343, 435, 3] ); 
            F.cdata = F.cdata(1:343,1:435,:);
        end;
        writeVideo(movObj, F);
    end;
end;

if make_movie
    close(movObj);
end;



end