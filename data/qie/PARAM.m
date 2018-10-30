%% Define Fourier operators
FT = @(x) fftshift(fft2(ifftshift(x)));    % Fourier transform
iFT = @(x) fftshift(ifft2(ifftshift(x)));  % inverse Fourier transform

ST = @(f,H) real(iFT(FT(f).*H));    % Define shift operator

%% Parameters of the capture system
NA = 1/2.5/2;    % numerical aperture of the camera
% NA = 1/2.5/5;    % numerical aperture of the camera
NI = 3;     % number of the captured images
dz = 50e-3;    % depth interval between two adjacent images
pps = 30.7e-4/2;   % pixel pitch of the camera sensor, magnification of camera  3.1e-5
z_scope = -50e-3:dz:50e-3;    % locations of the depth images
% M = 1;

z1 = -50e-3;   % Location of the first plane object
z2 = 50e-3;    % Location of the second plane object

M = 1;