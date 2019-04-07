function [xprime,z] = inverse_perspective(x,y)

z_near = 0.1;
z_far = 10000;
aspect_ratio = (4/3);
fov_x = 75.2*pi/180;
fov_y = fov_x / aspect_ratio;
eye_height = 2.5;

screen_halfheight = z_near * tan(fov_y/2);
screen_halfwidth = z_near * tan(fov_x/2);

norm_y = screen_halfheight * (384-y)/384;

z = eye_height * (z_near ./ norm_y);



norm_x = screen_halfwidth * (x-512)/512;

%gaze_angle = atan(norm_x./z_near);

xprime = z .* (norm_x ./ z_near);

% a norm_x of +/- 1 maps to +/- 10 in world coords


end
