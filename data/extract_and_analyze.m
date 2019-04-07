%[gaze starts seering trial_roads roads dists s_hdr g_hdr] = load_data({'subj2','subj3','subj4','subj5','subj6','subj7','subj8','subj9'});
%[gaze starts steering trial_roads roads dists s_hdr g_hdr] = load_data({'subj2','subj3'});

num_subj = size(gaze,1);
num_trials = size(gaze,2);
num_cols = length(g_hdr);


for subj = 1:num_subj
    for trial = 1:num_trials

        [globalt, newdist, newth] = sync_times((gaze(subj,trial,:,1)-starts(subj,trial))/1000,...
                dists(subj,trial,:),steering(subj,trial,:,1),steering(subj,trial,:,5),.002);
        clear new;
        for k=1:num_cols
%            [new_t, new(subj,trial,:,k)] = makeuniform(steering(subj,trial,:,1),...
%                steering(subj,trial,:,k), .002);
            [new_t, new(:,k)] = makeuniform(steering(subj,trial,:,1),...
                steering(subj,trial,:,k), .002);
        end;

        pos = extract_hand_pos(subj, trial, new);

        road_t = roads(trial_roads(subj,trial), 1:4000, 1)/2;
        mid_road = (roads(trial_roads(subj,trial), 1:4000, 2) + roads(trial_roads(subj,trial), 4001:end, 2))/2;

%        z = -squeeze(new(subj,trial,:,7));
        z = -squeeze(new(:,7));
        zt = road_t/max(z)*max(new_t);
        [xct, xcroad, xcpos] = sync_times(zt,mid_road,new_t,-pos,mean(diff(zt)));
        
        %xc(subj, trial, :) = xcov(xcroad, xcpos, 'coeff');
        
        [xcstats(subj,trial,:) interestingStates{subj,trial} goodStates{subj,trial} emptyStates{subj,trial}] = analyze_xc(xcroad', xcpos');
        tslen(subj,trial) = length(xcroad);
    
        
        
    end;
end;

