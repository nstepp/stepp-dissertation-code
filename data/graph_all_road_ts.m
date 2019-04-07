

[new_s_t2 new_s2(:,1)] = makeuniform(squeeze(steering(1,8,:,1), squeeze(steering(1,8,:,6)), 1/60);
[new_s_t2 new_s2(:,1)] = makeuniform(squeeze(steering(1,8,:,1)), squeeze(steering(1,8,:,6)), 1/60);
[new_s_t2 new_s2(:,2)] = makeuniform(squeeze(steering(1,8,:,1)), squeeze(steering(1,8,:,7)), 1/60);
[new_s_t2 new_s2(:,3)] = makeuniform(squeeze(steering(1,8,:,1)), squeeze(steering(1,8,:,5)), 1/60);
[new_s_t2 new_s2(:,4)] = makeuniform(squeeze(steering(1,8,:,1)), squeeze(steering(1,8,:,2)), 1/60);
figure;
trial_roads
road2(:,1) = roads(4,1:4000,2);
road2(:,2) = roads(4,4001:8000,2);

theta2 = (pi/2)*(new_s2(:,4)-512)/512;

hold on;plot(road_z,(road-50)/5,'k','linewidth',3);hold off;
for i=1:size(new_s,1), hold on; plot([-new_s(i,2) -new_s(i,2) + 10*cos(new_s(i,3))],[-new_s(i,1) -new_s(i,1) + 10*sin(new_s(i,3))],'r'); hold off; end;
hold on;plot(-new_s(:,2),10*new_s(:,3),'k--','linewidth',3);hold off;
hold on;plot(-new_s(:,2),-4*theta,'b','linewidth',3);hold off;

droad2(:,1) = deriv(road2(:,1),mean(diff(new_s2(:,2))));
droad2(:,2) = deriv(road2(:,2),mean(diff(new_s2(:,2))));
figure;
plot(road_z(1:end-1),droad2(:,:),'k','linewidth',3);
hold on;plot(-new_s2(:,2),-theta2,'b','linewidth',3);hold off;
