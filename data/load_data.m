function [gaze starts steering trial_roads roads dists saccs steering_headers eye_headers] = load_data(subjs)
% function [gaze starts steering trial_roads roads dists saccs steering_headers eye_headers] = load_data(subjs)
%
% subjs is a cell-array of subject data directories

% If we don't have a marker, guess that it took 16 ms
% from start of eye tracking to first steering frame.
% This number rarely deviates by more than 1 ms.
default_start = 16;

% truncate when time series are uneven
% we can afford to throw away 1 or 2 s at end
max_gaze_t = 29000;
max_steer_t = 3585;

steering_headers = {'time', 'steer_x', 'steer_y', 'steer_x_tau', 'angle', 'road_x', 'road_z'};
eye_headers = {'time','gaze_x','gaze_y','gaze_res','head_x','head_y','head_z'};

num_subjs = length(subjs);
num_trials = 16;

% Initialize large matricies
gaze = zeros(num_subjs, num_trials, max_gaze_t, length(eye_headers));
starts = zeros(num_subjs, num_trials);
dists = zeros(num_subjs, num_trials, max_gaze_t);
steering = zeros(num_subjs, num_trials, max_steer_t, length(steering_headers));

% XXX I'm assuming this is being run in the src directory.
%cd ../../data

% load road data.

road_inits = load('road_inits.txt');
num_roads = size(road_inits,1);

for i=1:num_roads
    roads(i,:,:) = load(['road' int2str(i) '.txt']);
end;

for s=1:num_subjs

	subj = subjs{s};

	cd(subj)

	listing = dir('gaze*.txt');

	trials = length(listing);

	disp(['Subj ' int2str(s)]);

	for i=1:trials
		tmpgaze = load(['gaze' int2str(i) '.txt']);
		gaze(s,i,:,:) = tmpgaze(1:max_gaze_t,:);
		starts(s,i) = load(['start' int2str(i) '.txt']);
        if starts(s,i) == 0
            starts(s,i) = gaze(s,i,1,1) + default_start;
        end;
        
        % clean gaze data of out of bounds gazes, then find
        % on-road distances
        tmpgaze(tmpgaze(1:max_gaze_t,3) >= 384,3) =  NaN;
        tmpgaze(tmpgaze(1:max_gaze_t,3) < 0,3) =  NaN;
        
		dists(s,i,:) = gaze_dist(tmpgaze(1:max_gaze_t,3));

		% Load saccade data
		% cell array due to variable number of saccades per trial
		saccs{s,i} = load(['saccs' int2str(i) '.txt']);
	end;

	listing = dir('steersim*.txt');

	for i=1:length(listing)
		seps = find(listing(i).name == '-',3,'first');
		trial = str2double(listing(i).name(seps(1)+1:seps(2)-1));
		if trial < 1
			continue;
		end;
		trial_roads(s,trial) = str2double(listing(i).name(seps(2)+1:seps(3)-1));
		tmp = load(listing(i).name);
		steering(s,trial,:,:) = tmp(1:max_steer_t,:);
	end;

	cd('..')
end;


