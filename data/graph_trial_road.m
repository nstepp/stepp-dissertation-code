function graph_trial_road(subj, trial, steering, gaze, starts, trial_roads, roads)

steering_t = squeeze(steering(subj,trial,:,1));
h = mean(diff(steering_t));

gaze_t = (squeeze(gaze(subj,trial,:,1))-starts(subj,trial))/1000;
gaze_h = mean(diff(gaze_t));

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
droad = deriv(road(:,1),mean(diff(road_z)));

theta = (pi/2)*(wheel_pos-512)/512;
theta_tau = (pi/2)*(wheel_pos_tau-512)/512;

figure;
% road
plot(road_z,(road-50)/5,'k','linewidth',3);
% road derivative
% hold on;plot(road_z,droad,'k:','linewidth',3);
% heading vectors
for i=1:length(pos_z)
    hold on;
    plot([-pos_z(i) -pos_z(i) + 10*cos(heading(i))],[-pos_x(i) -pos_x(i) + 10*sin(heading(i))],'r');
    hold off;
end;
% heading angle
% hold on;plot(-pos_z,heading,'k--','linewidth',3);hold off;
% steering angle
hold on;plot(-pos_z,-theta*10,'b','linewidth',3);hold off;
% hold on;plot(-pos_z,-theta_tau,'b--','linewidth',3);hold off;


% rotate all of the gaze coordinates by heading angle
for i=1:length(pos_z)
    th=heading(i);
    R = [cos(th) -sin(th);sin(th) cos(th)];
    gaze_vec(i,:) = R*[gaze_z(i) gaze_xprime(i)]';
end;
% now plot with origins at current road location
%hold on;plot([-pos_z; -pos_z + gaze_vec(:,1)'], [-pos_x; -pos_x + gaze_vec(:,2)'],'m','linewidth',2);hold off;
%hold on;plot(-pos_z + gaze_vec(:,1)', -pos_x + gaze_vec(:,2)','m','linewidth',2);hold off;
hold on;plot(-pos_z + gaze_vec(:,1)', -pos_x + gaze_vec(:,2)','m.-');hold off;

axis([0 ceil(max(-pos_z)) -20 20]);
set(gca,'fontsize', 18);
xlabel('z (ground)');
ylabel('x\prime (ground), \theta (rad \times 10)');

%figure; hist(gaze_z,(1:5:60));

end
