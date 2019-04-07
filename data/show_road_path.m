function show_road_path(subj, trial, steering, roads, trial_roads)

road = trial_roads(subj, trial);

x = squeeze(steering(subj,trial,:,6));
z = squeeze(steering(subj,trial,:,7));
th = squeeze(steering(subj,trial,:,5));
t = squeeze(steering(subj,trial,:,1));
pos_x = squeeze(steering(subj,trial,:,2));

pos_th = (pi/2)*(pos_x-512)/512;

pos = cumsum(cumsum(pos_th)*mean(diff(t)))*sqrt(mean(diff(t)));

figure;plot(roads(road,:,1)/2,-roads(road,:,2)/5 + 10,'.')
hold on;
plot(-z,x,'r');
plot(-z,pos,'g');
hold off;

end
