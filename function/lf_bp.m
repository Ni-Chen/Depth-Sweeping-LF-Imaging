%{
----------------------------------------------------------------------------------------------------
Name: Light field reconstruction with back propagation approach.

Author:   Ni Chen (ni_chen@163.com)
Date:     Aug. 2015
Modified: With deblur by Ni Chen on Dec. 30, 2015

Reference:
-J.-H. Park, "Light ray field capture using focal plane sweeping and its optical reconstruction
using 3D displays", Optics Express, 2014.

Copyright (2016): Ni Chen (ni_chen@163.com)
This program is free software; you can redistribute it and/or modify it under the terms of the GNU 
General Public License as published by the Free Software Foundation; either version 2 of the License
, or (at your option) any later version.
--------------------------------------------------------------------------------------
%}

function result = lf_bp(I_stack_dir, outDir, pps, ptt, Ntt, isOutParaImg, isDeblur)

    % Load the parameters of the camera
    addpath(I_stack_dir);
    PARAM();
    rmpath(I_stack_dir);

    %% Load stack images
    imgArray = cell(1, NI);
    disp('Loading image stack...');
    for iImg = 1:NI
        imgArray{iImg} = (imread([I_stack_dir, num2str(iImg), '.tif'], 'tif'));
    end
    
    [Ny, Nx, Nc] = size(imgArray{1});

    % interval of tan(theta)
    Ntty = Ntt(1);
    Nttx = Ntt(2);
    
    ptty = ptt(1);
    pttx = ptt(2);
    
    ttx = ((1:Nttx)-round(Nttx/2))*pttx;
    tty = ((1:Ntty)-round(Ntty/2))*ptty;

%     % Magnification of the photo compare to the focal photo
%     M = 1;    % For just simulation, since we don't consider mag in teh photo generation

    % Length of the captured photoes
    Lx = Nx*pps;
    Ly = Ny*pps;

   % Sampling of the captured photoes
    x = ((1:Nx) - round(Nx/2))*pps;
    y = ((1:Ny) - round(Ny/2))*pps;

    %% Calculate LF from a series of intensity images
    disp('Claculating ligth field......');
    if ~isOutParaImg
        LF = zeros(Ny, Nx, Ntty, Nttx, Nc);    % LF at the center focal plane of the camera
    end
   
    %% deblur, modified on Dec. 30, 2015
    if isDeblur
        dilateballsize = 67; %size of dilation ball
        kerSize = 51;  %size of gauss and laplace kernels
        imgArray = imgStackBright(imgArray);
        imgArray = imgStackDeblur(imgArray, kerSize, dilateballsize);
    end
       
    for itty = 1:Ntty
        ty = tty(itty);

        for ittx = 1:Nttx
            tx = ttx(ittx);
            paraImg = zeros(Ny, Nx, Nc);    % This is very important.
            temp = zeros(Ny, Nx, Nc);

            for iImg = 1:NI
                
                zn = z_scope(iImg);    % z position of the photo
                In = imgArray{iImg};

                % corresponding coordinates in the photo plane, (x, y) is in the LF                
                x_prime = (x + zn*tx)/M;
                y_prime = (y + zn*ty)/M;
                
                % index of the correspondig coordinates in the photo plane
                ix_prime = round((x_prime + Lx/2)./pps);
                iy_prime = round((y_prime + Ly/2)./pps);

                % check whether the index is whithin the photo boundary
                ix_prime(ix_prime<1)  = 1;
                ix_prime(ix_prime>Nx) = Nx;
                iy_prime(iy_prime<1)  = 1;
                iy_prime(iy_prime>Ny) = Ny;

                % the index in the LF which corresponding to the pixels within the intensity images
                [~, ix_]= find(abs(x_prime) <= Lx/2);
                [~, iy_]= find(abs(y_prime) <= Ly/2);

                temp(iy_, ix_, :) = In(iy_prime(iy_), ix_prime(ix_), :);             
                
                paraImg = paraImg + temp; 
            end

            if isOutParaImg  % Output parallex images to a folder
                temp = Toxy(paraImg, 0, 2^16-1);
                imwrite(uint8(temp), [outDir, 'ParaImg', '(', num2str(ittx), ',', num2str(itty), ').jpg'], 'jpg');
            else    % Output LF
                LF(:, :, itty, ittx, :) = paraImg/NI;                
            end
        end
        disp([num2str(ittx*itty/Nttx/Ntty*100), '% is finished~~']);
    end
    
    if isOutParaImg  % Output parallex images to a folder
        result = 1;
    else   % Output LF
        result = LF;     
    end
end