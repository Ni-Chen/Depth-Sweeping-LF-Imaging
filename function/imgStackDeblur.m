%{
----------------------------------------------------------------------------------------------------
Name: Image stack deblur

Author:   Ni Chen (ni_chen@163.com)
Date:     Aug. 2015
Modified: With deblur by Ni Chen on Dec. 30, 2015
Description: Remove blurness of the images in a focus sweep stack.
Reference:


Copyright (2015): Ni Chen (ni_chen@163.com)
This program is free software; you can redistribute it and/or modify it under the terms of the GNU 
General Public License as published by the Free Software Foundation; either version 2 of the License
, or (at your option) any later version.
--------------------------------------------------------------------------------------
%}
function [newImgArray] = imgStackDeblur(imgArray, kerSize, dilateballsize)
    [~, ImgNo] = size(imgArray);
    ImgArrBW = cell(1, ImgNo);
    
    %% Build laplace and gauss (instead of using inbuilt 'fspecial')
    Gauss = zeros(kerSize, kerSize);
    Laplace = zeros(kerSize, kerSize);
    Mid = ceil(kerSize/2);
    c = 1;
    for n = 1:kerSize
        for iy = 1:kerSize
            x = n - Mid;
            y = iy - Mid;
            Laplace(n, iy) = (-1/pi/c/c/c/c)*(1-(x*x+y*y)/2/c/c)*exp(-(x*x+y*y)/2/c/c);
            Gauss(n, iy) = exp(-(x*x/2/c/c + y*y/2/c/c));
        end
    end
    
    %% edge detection
    for n = 1:ImgNo
        Temp = conv2(double(imgArray{n}(:, :, 1)) + double(imgArray{n}(:, :, 2)) + double(imgArray{n}(:, :, 3)), Gauss, 'same');  % reduce noise
        ImgArrBW{n} = conv2(Temp, Laplace, 'same');   % 2nd gradient,
        B = size(ImgArrBW{n});
        ImgArrBW{n} = abs(ImgArrBW{n});

        %do a dilate? Seems to work okay, fill zero
        if (dilateballsize > 0)    
%             MidBall = ceil(dilateballsize/2);
            se = strel('ball', dilateballsize, dilateballsize);
            ImgArrBW{n} = imdilate(ImgArrBW{n}, se, 'same');
        end
     end
    
     [Ny, Nx] = size(ImgArrBW{1});
     SliceNo = ones(Ny, Nx);
     SliceVal = zeros(Ny, Nx);
     for n = 1:ImgNo
         for iy = 1:Ny
             for ix = 1:Nx
                 if( SliceVal(iy, ix) <= ImgArrBW{n}(iy, ix) )
                      SliceVal(iy, ix) = ImgArrBW{n}(iy, ix);
                      SliceNo(iy, ix) = n;
                 end
             end
         end
     end
     
    % Blur stack if needed for blending
    BlurSize = kerSize;    
%     SliceNo = conv2(SliceNo, fspecial('gaussian', [20 20], 20), 'same');
        
    %% Make new image array 
    newImgArray = cell(1, ImgNo);
    SliceNo = uint16(SliceNo);
    for n = 1:ImgNo
        tempImg = zeros(Ny, Nx, 3);
        iNoneZero = uint8(SliceNo==n);
%         h = fspecial('gaussian', 25, 25);
%         iNoneZero = imfilter(iNoneZero, h, 'circular');

        for iC= 1:3
            temp = imgArray{n}(:, :, iC).*iNoneZero;
            tempImg(:, :, iC) = temp;
        end
        
%         tempImg(tempImg<30)=0;
        
        newImgArray{n} = tempImg;
        imwrite(uint8( tempImg), [num2str(n), 'slice.jpg']);
    end
    
end