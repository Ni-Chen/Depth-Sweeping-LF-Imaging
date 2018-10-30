%{
--------------------------------------------------------------------------------------
    Name: Light field reconstruction with back propagation approach.
    
    Author:   Ni Chen (ni_chen@163.com)
    Date:     Aug. 2015
    Modified:

    Reference:
    -J.-H. Park, "Light ray field capture using focal plane sweeping and its
     optical reconstruction using 3D displays", OE, 2014.
--------------------------------------------------------------------------------------
%}

close all;
clear;
clc;

%% paramters
expName = 'IU';    % expName = 'NA'/'OSA'/'flower'/'IU/wenzi';
 
% file directory
inDir = ['./data/', expName, '/'];
outDir = ['./output/', expName, '/'];

% Load the parameters of the camera
% addpath(inDir); PARAM(); rmpath(inDir);   % For expereiment
run([inDir, 'PARAM.m']);

% number of parallax
Nttx = 100;
Ntty = 1;

if Nttx > 3 || Ntty > 3
    isOutImg = 0;
else
    isOutImg = 1;
end

% interval of tan(theta)
% pttx = tan(2*asin(NA)/Nttx);
% ptty = tan(2*asin(NA)/Ntty);
ptx = (2*asin(NA)/Nttx);
pty = (2*asin(NA)/Ntty);
% ptx = tan(2*asin(NA/Nttx));
% pty = tan(2*asin(NA/Ntty));

% ptx = tan(2*asin(NA/Nttx/3));
% pty = tan(2*asin(NA/Ntty/3));


%% Calculate LF
isOutParaImg = 0;   % whether output all parallex images
% save([outDir, 'parameters.mat'], 'NI', 'type','NA','f', 'pps', 'dz', 'z_scope', 'z1', 'z2', 'Nttx', 'Ntty', 'ptx', 'pty');
save([outDir, 'parameters.mat'], 'NI', 'NA', 'pps', 'dz', 'z_scope', 'z1', 'z2', 'Nttx', 'Ntty', 'ptx', 'pty');
% save([outDir, 'parameters.mat'], 'NI', 'NA', 'pps', 'dz', 'Nttx', 'Ntty', 'ptx', 'pty');

isDeblur = 0;
LF = lf_bp(inDir, outDir, pps, [pty ptx], [Ntty Nttx], isOutParaImg, isDeblur);

% Propagate to focused plane
% LF = lf_prop(LF, pps, [pty ptx], z1, 2);
    
%% Extract and display horizontal LF(x, tan(theta_x))
if ~isOutParaImg
    [Ny, Nx, N_ThetaY, N_ThetaX, Nc] = size(LF);
    LF_x_ttx = zeros(Nx, N_ThetaX, Nc);
    
    for ix_prime = 1:Nx
        for itx = 1:N_ThetaX
            LF_x_ttx(ix_prime, itx, :) = LF(round(1*Ny/2), ix_prime, round(N_ThetaY/2), itx, :);
%              LF_x_ttx(ix_prime, itx, :) = LF(round(2*Ny/5), ix_prime, round(N_ThetaY/2), itx, :);
%              LF_x_ttx(ix_prime, itx, :) = LF(round(5*Ny/6), ix_prime, round(N_ThetaY/2), itx, :);
        end
    end

%     LF_x_ttx = zeros(Ny, N_ThetaY, Nc);    
%     for iy_prime = 1:Ny
%         for ity = 1:N_ThetaY
%             LF_x_ttx(iy_prime, ity, :) = LF(iy_prime, 150, ity, round(N_ThetaX/2), :);
%         end
%     end
    
    %% output
    if isOutImg == 0
        %% Display LF
        temp = imrotate(LF_x_ttx, 90);
        temp = Toxy(temp, 0, 255);
        figure;
        imshow(uint8(temp), []);
%         imagesc(x, atan(ttx)/pi*180, uint8(temp));
%         set(gca,'YDir','normal');
        xlabel('x');
        ylabel('{\theta_x}(degree)');
        saveas(gcf, [outDir, 'x-ttx_z0_',num2str(isDeblur),'.jpg'],'jpg');
             
        set(gcf, 'paperpositionmode', 'auto');
        if isDeblur
%             print('-depsc', [outDir, 'exp_x_ttx_NI', num2str(NI), '_p1_deblur.eps']);
            imwrite(uint8(temp), [outDir, 'x_ttx_NI', num2str(NI), '_p1_deblur.jpg'], 'jpg');  
        else
%             print('-depsc', [outDir, 'exp_x_ttx_NI', num2str(NI), '_p1.eps']);
            imwrite(uint8(temp), [outDir, 'x_ttx_NI', num2str(NI), '_p1.jpg'], 'jpg');  
        end
        
%         % LF at focused plane
%         LF_prime = lf_prop(LF_x_ttx, pps, ptx, z1, 2);
%         %     LF_prime = lf_prop(LF_x_ttx, pps, ptx, [z1 z2 50e-3], 3);
%         temp = imrotate(LF_prime, 90);
%         temp = Toxy(temp, 0, 255);
%         imwrite(uint8(temp), [outDir, 'x-ttx_z1.jpg'],'jpg');
%         
%         LF_prime = lf_prop(LF_x_ttx, pps, ptx, z2, 2);
%         temp = imrotate(LF_prime, 90);
%         temp = Toxy(temp, 0, 255);
%         imwrite(uint8(temp), [outDir, 'x-ttx_z2.jpg'],'jpg');
        
        %% Refocuse intensity images at different depth
        n=0;
        z_scope = -50e-3:100e-3:50e-3; 
%         z_scope = -20e-6:20e-6:20e-6; 
        for zn = z_scope    % z position of the photo
            n = n + 1;
            Iz = lf_proj2Img(LF, pps, NA, zn, 1);
            temp = Toxy(Iz, 0, 255);
            imwrite(uint8(temp), [outDir, num2str(NI), '_',num2str(isDeblur),'_',num2str(zn*1000),'.jpg'],'jpg');
            disp([num2str(n/7*100), '% is finished~~']);
            
%             figure;
%             imshow(uint8(temp), []);
%             set(gcf,'paperpositionmode','auto');
%             print('-depsc', [outDir, 'deblur_', num2str(zn*1000), '.eps']);
        end
    else
        %% Display parallax view images
        viewImg = zeros(Ny, Nx, Nc);
        for ittx = 1:Nttx
            for itty = 1:Ntty
                viewImg(1:Ny, 1:Nx, :) = LF(:, :, itty, ittx, :);
                temp = Toxy(viewImg, 0, 255);
                imwrite(uint8(temp), [outDir, 'ParaImg(', num2str(ittx), ',', num2str(itty), ').jpg'], 'jpg');
            end
        end
    end    
    
end
