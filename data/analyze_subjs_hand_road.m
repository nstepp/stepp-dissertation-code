
clear xcstats_HdR xcstats_HddR xcstats_HkR xcstats_VR xcstats_DdR rho_tau
clear hxcstats_HdR hxcstats_HddR xcstats_HkR hxcstats_VR hxcstats_DdR hrho_tau

for s=1:8
    for trial=1:16
        disp([int2str(s) ',' int2str(trial)]);
        disp('Full...');
        [xcstats_HdR(s,trial,:) xcstats_HddR(s,trial,:) ...
         xcstats_HkR(s,trial,:) xcstats_VR(s,trial,:) ...
         xcstats_DdR(s,trial,:) rho_tau(s,trial) ...
        ] = analyze_hand_road(s, trial, steering, trial_roads, roads);

        disp('Last half...');
        [hxcstats_HdR(s,trial,:) hxcstats_HddR(s,trial,:) ...
         hxcstats_HkR(s,trial,:) hxcstats_VR(s,trial,:) ...
         hxcstats_DdR(s,trial,:) hrho_tau(s,trial) ...
        ] = analyze_hand_road(s, trial, steering, trial_roads, roads, 0.5);
    end;
end;
