NI = 21;    % NUmber of intensity images

%% Parameters of the camera

NA = 0.4;    % Numerical aperture of the camera, larger NA -> larger parallax -> more blur LF
f = 50e-3;      % focal length of the camera, affect the blur with NA together

pps = 1e-3;      % Pixel pitch of the camera sensor
Ns = 500;

% The camera location for a series of captured images along the optical axis.
dz = 5e-3;
z_max = dz*(NI-1)/2;
z_min = -z_max;
z_scope = z_min:dz:z_max;

z1 = -15e-3;
z2 = 15e-3;
M=1;