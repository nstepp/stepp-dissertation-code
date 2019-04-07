
% feeling lazy....
num_subjs = 8;
num_trials = 16;
num_cols = 7;


for i=1:num_subjs
	for j=1:num_trials
		[globalt, newdist, newth] = sync_times((gaze(i,j,:,1)-starts(i,j))/1000,...
				dists(i,j,:),steering(i,j,:,1),steering(i,j,:,5),.002);
		for k=1:num_cols
			[new_t, new(i,j,:,k)] = makeuniform(steering(i,j,:,1), steering(i,j,:,k),...
				.002);
		end;
	end;
end;

