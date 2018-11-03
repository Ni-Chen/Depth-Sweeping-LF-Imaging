%{
--------------------------------------------------------------------------------------
Simulation data  in paper of "Analysis of the noise in back-projection light field 
acquisition and its optimization", AO 56(13):F20-F26, 2017. 
--------------------------------------------------------------------------------------
%}

NI = 5;    % Number of intensity images

M = 1;

%% Parameters of the camera

NA = 0.5;    % Numerical aperture of the camera, larger NA -> larger parallax -> more blur LF
f = 100e-3;      % focal length of the camera, affect the blur with NA together

pps = 1e-3;      % Pixel pitch of the camera sensor
Ns = 500;

% The camera location for a series of captured images along the optical axis.
dz = 10e-3;
z_max = dz*(NI-1)/2;
z_min = -z_max;
z_scope = z_min:dz:z_max;

z1 = -20e-3;
z2 = 0e-3;
z3 = 20e-3;