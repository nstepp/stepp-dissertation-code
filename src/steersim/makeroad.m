function road = makeroad(x)

road_t = [(0.5:0.5:2000) (0.5:0.5:2000)];

roadL = x(1:4000,1);
roadR = roadL - 0.5;

road = [roadR; roadL];
road = road - min(road);
road = 100 * (road/max(road));

road(:,2) = road;
road(:,1) = road_t;


