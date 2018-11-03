function imgArray = imgStackBright(imgArray)
    %% Adjust image brightnesses to all match (make all same level)
    [~, ImgNo] = size(imgArray);
    brightAver = mean2(rgb2gray(imgArray{1}));  % Brightness reference

    for n = 2:ImgNo
        iBright = mean2(rgb2gray(imgArray{n}));
        imgArray{n} = imgArray{n} + (brightAver-iBright);
    end
end