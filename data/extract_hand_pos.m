function pos = extract_hand_pos(subj, trial, steering)

%t = squeeze(steering(subj,trial,:,1));
%pos_x = squeeze(steering(subj,trial,:,2));
t = squeeze(steering(:,1));
pos_x = squeeze(steering(:,2));

pos_th = (pi/2)*(pos_x-512)/512;

pos = cumsum(cumsum(pos_th)*mean(diff(t)))*sqrt(mean(diff(t)));

end