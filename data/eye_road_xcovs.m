function [xcstats hs] = eye_road_xcovs(data)

subjs = size(data.pos_z,1);
trials = size(data.pos_z,2);
tsLen = size(data.pos_z,3);

% make the gaze time series in road units.
gaze_ts_z = -data.pos_z + data.gaze_vec(:,:,:,1);
gaze_ts_x = -data.pos_x + data.gaze_vec(:,:,:,2);

for s=1:subjs
    for t=1:trials

        disp(['(' int2str(s) ',' int2str(t) ')']);     
        
        % filter to get coarse behavior
        h = mean(diff(-data.pos_z(s,t,:)));
        [B,A] = butter(4,2*h*0.1);

        gaze_ts_x(s,t,:) = filtfilt(B,A,squeeze(gaze_ts_x(s,t,:)));

        % crop the road down to the extent of gaze
        road = squeeze(data.road_z(s,t,:));

        last_z = -data.pos_z(s,t,end);
        gaze_ts_rs = interp_over_time(road,-squeeze(data.pos_z(s,t,:)),squeeze(gaze_ts_x(s,t,:)));

        last_z_ind = find( road <= last_z, 1, 'last' );

        xcstats(s,t,:) = analyze_xc(squeeze(data.road(s,t,1:last_z_ind)), gaze_ts_rs(1:last_z_ind));
        hs(s,t) = h;
    end;
end;

end