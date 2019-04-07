function [xcstats_HdR xcstats_HddR xcstats_HkR xcstats_VR xcstats_DdR rho_tau] = analyze_hand_road(subj, trial, steering, trial_roads, roads, skip_pct)

if nargin < 6
    skip_pct = 0;
end;

steering_t = squeeze(steering(subj,trial,:,1));
h = mean(diff(steering_t));

[~, pos_x] = makeuniform(steering_t, squeeze(steering(subj,trial,:,6)), h);
[~, pos_z] = makeuniform(steering_t, squeeze(steering(subj,trial,:,7)), h);
[~, heading] = makeuniform(steering_t, squeeze(steering(subj,trial,:,5)), h);
% steering position
[~, wheel_pos] = makeuniform(steering_t, squeeze(steering(subj,trial,:,2)), h);
% delayed steering position
[~, wheel_pos_tau] = makeuniform(steering_t, squeeze(steering(subj,trial,:,4)), h);

road(:,1) = roads(trial_roads(subj,trial),1:4000,2);
road(:,2) = roads(trial_roads(subj,trial),4001:8000,2);
road_z = (1:4000)/4;
droad = deriv(road(:,1), 1/mean(diff(road_z)));

ddroad = deriv(droad, 1);

theta = (pi/2)*(wheel_pos-512)/512;
theta_tau = (pi/2)*(wheel_pos_tau-512)/512;

[~, m, s] = sync_times(road_z, droad, -pos_z, -theta, mean(diff(-pos_z)));
% This skip will be the same in all cases below
skip = floor(skip_pct * length(m));
m = m(1+skip:end);
s = s(1+skip:end);
xcstats_HdR = analyze_xc(m', s');
xcstats_HdR(9) = length(m);

[~, m, s] = sync_times(road_z, ddroad, -pos_z, -theta, mean(diff(-pos_z)));
m = m(1+skip:end);
s = s(1+skip:end);
xcstats_HddR = analyze_xc(m', s');
xcstats_HddR(9) = length(m);

[~, m, s] = sync_times(road_z, droad, -pos_z, -theta_tau, mean(diff(-pos_z)));
m = m(1+skip:end);
s = s(1+skip:end);
rho_tau = corr(m',s');

[~, m, s] = sync_times(road_z, road(:,1), -pos_z, -pos_x, mean(diff(-pos_z)));
m = m(1+skip:end);
s = s(1+skip:end);
xcstats_VR = analyze_xc(m', s');
xcstats_VR(9) = length(m);

[~, m, s] = sync_times(road_z, droad, -pos_z, heading, mean(diff(-pos_z)));
m = m(1+skip:end);
s = s(1+skip:end);
xcstats_DdR = analyze_xc(m', s');
xcstats_DdR(9) = length(m);

% curvature defined by:
%            y''
% k = -----------------
%     (1+y'^2)^(3/2)

kroad = ddroad / (1+droad.^2).^(3/2);

[~, m, s] = sync_times(road_z, kroad, -pos_z, -theta, mean(diff(-pos_z)));
m = m(1+skip:end);
s = s(1+skip:end);
xcstats_HkR = analyze_xc(m', s');
xcstats_HkR(9) = length(m);


end



