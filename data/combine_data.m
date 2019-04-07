function resamp_data = combine_data(steering, gaze, starts, trial_roads, roads)

% Get all subjects and all time-series in the same time units

subjs = size(steering,1);
trials = size(steering,2);
stsLen = size(steering,3);
gtsLen = size(gaze,3);

% create a mean time vector
steering_t = mean( reshape(squeeze(steering(:,:,:,1)), subjs*trials, stsLen), 1);

%steering_t = squeeze(steering(subj,trial,:,1));
h = mean(diff(steering_t));

resamp_data.steering_t = steering_t;
resamp_data.steering_h = h;

% do the same for the eye data
%gaze_t = (squeeze(gaze(subj,trial,:,1))-starts(subj,trial))/1000;
gaze_t = mean( reshape(squeeze(gaze(:,:,:,1))-repmat(starts(:,:),[1 1 gtsLen]), subjs*trials, gtsLen), 1)/1000;

gaze_h = mean(diff(gaze_t));

resamp_data.gaze_t = gaze_t;
resamp_data.gaze_h = gaze_h;

% Put all steering data onto the new mean time vector

for subj = 1:subjs
    for trial = 1:trials
        disp(['(' int2str(subj) ',' int2str(trial) ')']);
        
        % road x
        [t, pos_x] =  makeuniform(steering_t, squeeze(steering(subj,trial,:,6)), h);
        % road z
        [~, pos_z] = makeuniform(steering_t, squeeze(steering(subj,trial,:,7)), h);
        % heading
        [~, heading] = makeuniform(steering_t, squeeze(steering(subj,trial,:,5)), h);
        % steering position
        [~, wheel_pos] = makeuniform(steering_t, squeeze(steering(subj,trial,:,2)), h);
        % delayed steering position
        [~, wheel_pos_tau] = makeuniform(steering_t, squeeze(steering(subj,trial,:,4)), h);

        resamp_data.pos_x(subj,trial,:) = pos_x;
        resamp_data.pos_z(subj,trial,:) = pos_z;
        resamp_data.heading(subj,trial,:) = heading;
        resamp_data.wheel_pos(subj,trial,:) = wheel_pos;
        resamp_data.wheel_pos_tau(subj,trial,:) = wheel_pos_tau;

        % gaze position -- massive downsampling here
        %gaze_x = resample(squeeze(gaze(subj,trial,:,2)), ceil(1/h), ceil(1/gaze_h));
        %[gaze_t_ds,gaze_x] = makeuniform(gaze_t, squeeze(gaze(subj,trial,:,2)), h);
        %[~,gaze_y] = makeuniform(gaze_t, squeeze(gaze(subj,trial,:,3)), h);

        gaze_x = squeeze(gaze(subj,trial,:,2)); 
        gaze_y = squeeze(gaze(subj,trial,:,3)); 

        % we are only interested in gaze locations on the screen
        g_screen = gaze_x > 0 & gaze_x <= 1024 & gaze_y > 0 & gaze_y < 384;

        gaze_x_ds = interp_over_time(t,gaze_t(g_screen)', gaze_x(g_screen));
        gaze_y_ds = interp_over_time(t,gaze_t(g_screen)', gaze_y(g_screen));

        [gaze_xprime, gaze_z] = inverse_perspective(gaze_x_ds,gaze_y_ds);

        resamp_data.gaze_x(subj,trial,:) = gaze_x_ds;
        resamp_data.gaze_y(subj,trial,:) = gaze_y_ds;
        resamp_data.gaze_xprime(subj,trial,:) = gaze_xprime;
        resamp_data.gaze_z(subj,trial,:) = gaze_z;

        road(:,1) = roads(trial_roads(subj,trial),1:4000,2);
        road(:,2) = roads(trial_roads(subj,trial),4001:8000,2);
        road_z = (1:4000)/4;
        droad = deriv(road(:,1),mean(diff(road_z)));

        resamp_data.droad(subj,trial,:) = interp_over_time(linspace(0,1000,length(t)),road_z',droad);
        resamp_data.road_z(subj,trial,:) = interp_over_time(linspace(0,1000,length(t)),road_z',road_z');
        resamp_data.road(subj,trial,:) = interp_over_time(linspace(0,1000,length(t)),road_z',road(:,1));

        theta = (pi/2)*(wheel_pos-512)/512;
        theta_tau = (pi/2)*(wheel_pos_tau-512)/512;

        resamp_data.theta(subj,trial,:) = theta;
        resamp_data.theta_tau(subj,trial,:) = theta_tau;

        % rotate all of the gaze coordinates by heading angle
        for i=1:length(pos_z)
            th=heading(i);
            R = [cos(th) -sin(th);sin(th) cos(th)];
            gaze_vec(i,:) = R*[gaze_z(i) gaze_xprime(i)]';
        end;

        resamp_data.gaze_vec(subj,trial,:,:) = gaze_vec;

    end;
end;


end
