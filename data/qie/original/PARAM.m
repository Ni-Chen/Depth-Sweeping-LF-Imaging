%% Define Fourier operators
FT = @(x) fftshift(fft2(ifftshift(x)));    % Fourier transform
iFT = @(x) fftshift(ifft2(ifftshift(x)));  % inverse Fourier transform

ST = @(f,H) real(iFT(FT(f).*H));    % Define shift operator

%% Parameters of the capture system
NA = 1/1.2/2;    % numerical aperture of the camera
NI = 21;     % number of the captured images
dz = 5e-3;    % depth interval between two adjacent images
pps = 31e-4;   % pixel pitch of the camera sensor
z_scope = -50e-3:dz:50e-3;    % locations of the depth images

z1 = -50e-3;   % Location of the first plane object
z2 = 50e-3;    % Location of the second plane object
