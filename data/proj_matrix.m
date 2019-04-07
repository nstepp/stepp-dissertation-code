function matrix = proj_matrix(fov_x, z_clip_near, z_clip_far, aspect_ratio)
% function matrix = proj_matrix(fov_x=45.0,z_clip_near = 0.1,z_clip_far=10000.0,aspect_ratio=4.0/3.0)
%
% Compute a 4x4 projection matrix that performs a perspective distortion.

%fov_x=45.0,z_clip_near = 0.1,z_clip_far=10000.0,aspect_ratio=4.0/3.0

if nargin < 2
    z_clip_near = 0.1;
end;
if nargin < 3
    z_clip_far = 10000.0;
end;
if nargin < 4
    aspect_ratio = 4/3;
end;

fov_y = fov_x / aspect_ratio;
radians = fov_y / 2.0 * pi / 180.0;
delta_z = z_clip_far - z_clip_near;
sine = sin(radians);

if delta_z == 0.0 || sine == 0.0 || aspect_ratio == 0.0
    error('Invalid parameters passed to SimpleProjection.__init__()');
end;

cotangent = cos(radians) / sine;

matrix = zeros(4,4);

matrix(1,1) = cotangent/aspect_ratio;
matrix(2,2) = cotangent;
matrix(3,3) = -(z_clip_far + z_clip_near) / delta_z;
matrix(3,4) = -1.0; % XXX this
matrix(4,3) = -2.0 * z_clip_near * z_clip_far / delta_z; % XXX and this might cause the matrix to need to be transposed
matrix(4,4) = 0.0;

end


