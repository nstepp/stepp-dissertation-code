function plot_saccs(saccs)


for i=1:size(saccs,1)
    plot3(saccs(i,1:2),saccs(i,[4,6]),saccs(i,[5,7]));
    plot3(saccs(i,1),saccs(i,4),saccs(i,5),'.g');
    plot3(saccs(i,2),saccs(i,6),saccs(i,7),'.r');
    hold on;
end;
hold off;
grid on;
axis vis3d;
xlabel('time');
ylabel('x');
zlabel('y');



end