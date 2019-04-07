
screenSize = get(0, 'ScreenSize');

width = screenSize(3);
height = screenSize(4);


pos = dash(1,:);
pos(2) = 0;

th = 0;

%for i=1:3500
while pos(3) <= roadR(end,3)
    pointer = get(0,'PointerLocation');
    v = 3*pointer(2)/height;
    th = th + v*(-(pi/6) * (pointer(1) - (width/2))/(width/2));
    %th = (-(pi/6) * (pointer(1) - (width/2))/(width/2));
    newRoadR = perspective(roadR,pos,th);
    newRoadL = perspective(roadL,pos,th);
    newDash = perspective(dashed,pos,th);
    plot(newDash(:,1),newDash(:,2),'r.');
    hold on;
    plot(newRoadR(:,1),newRoadR(:,2),'k.',newRoadL(:,1),newRoadL(:,2),'k.',pos(1),pos(3),'.');
    hold off;
    axis([-1 1 -1 1]);
    pause(0.1);
    pos(1) = pos(1)+v*sin(-th);
    pos(3) = pos(3)+v*cos(-th);
    %pos(3) = roadR(i,3);
end;
