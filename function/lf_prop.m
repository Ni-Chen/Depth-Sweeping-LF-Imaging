%{
--------------------------------------------------------------------------------------
    Name:     LF transformation 
    Author:   Ni Chen (ni_chen@163.com)
    Date:     May. 2015
    Modified:  

    Description: 
    - LF(y_prime, x_prime, tty_prime, ttx_prime) = lf_prop(LF(y, x, tty, ttx), pxy, pttxy, fz, trans_type)
    - LF(x_prime, ttx_prime) and LF(x, ttx) have the same sampling strategy.
--------------------------------------------------------------------------------------
%}

function LF_new = lf_prop(LF, pxy, ptt, fz, trans_type)
    LF_new = 0*LF;    % Light field after the transformation
    
    n = ndims(LF);    % dimension of the LF

    if n <= 3
        %% 2D LF transformation
        [Nx, Nttx, Nc] = size(LF);
        
        x = ((1:Nx)-Nx/2)*pxy;    % x axis of the LF        
        Lx = Nx*pxy;     
        
        pttx = ptt;
        ttx = ((1:Nttx)-Nttx/2)*pttx;    % tan(theta) of the LF        
        Lttx = Nttx*pttx;
        
        switch trans_type
            case 1
                % For lens transformation, where the focal length of lens is fz
                traMat = [  1     0;
                          -1/fz   1];
                      
                for ix = 1:Nx
                    ttx_prime = x(ix).*traMat(2,1) + ttx;
                    ittx_prime = round((ttx_prime + Lttx/2)/pttx);
                    
                    ittx_prime(ittx_prime<1) = 1;
                    ittx_prime(ittx_prime>Nttx) = Nttx;
                    
                    [temp1, ittx_]= find(abs(ttx_prime) <= Lttx/2);
                    
                    LF_new(ix, ittx_prime(ittx_), :) = LF(ix, ittx_, :);
                end
                
            case 2
                % For propagation with a distance fz
                traMat = [1    fz; ...
                          0    1];
                for ittx = 1:Nttx
                    x_prime = x + traMat(1,2)* ttx(ittx);
                    ix_prime = round((x_prime + Lx/2)/pxy);
                    
                    ix_prime(ix_prime<1)  = 1;
                    ix_prime(ix_prime>Nx) = Nx;
                    
                    [temp1, ix_]= find(abs(x_prime) <= Lx/2);
                    
                    LF_new(ix_prime(ix_), ittx, :) = LF(ix_, ittx, :);
                end
                
            case 3
                % From object focal plane to the sensor plane, fz = [zoc zs],
                % where zoc is the DOF of the object,  zs is the distance from
                % the lens to the sensor,  f is the focal length of the lens
                traMat = [-fz(2)/fz(1),        0;           ...
                          -1/fz(1)-1/fz(2),   -fz(1)/fz(2)];    %% C*B*A
                
                for ix = 1:Nx
                    x_val = x(ix);
                    
                    for ittx = 1:Nttx
                        ttx_val = ttx(ittx);
                        
                        x_prime = traMat(1, 1)*x_val + traMat(1, 2)*ttx_val;
                        ttx_prime = traMat(2, 1)*x_val + traMat(2, 2)*ttx_val;
                        
                        ix_prime = round((x_prime + Lx/2)/pxy);
                        ittx_prime = round((ttx_prime + Lttx/2)/pttx);
                        
                        if(ix_prime > 0) && (ix_prime <= Nx) && (ittx_prime >0) && (ittx_prime <= Nttx)
                            LF_new(ix_prime, ittx_prime, :) = LF(ix, ittx, :);
                        end
                    end
                end
                
            case 4
                % From the sensor plane to the object focal plane, fz = [zoc zs f],
                traMat = [-fz(1)/fz(2)         0; ...
                    1/fz(1)+1/fz(2)  -fz(2)/fz(1)];
                
            otherwise
                disp(['LF type should be:', char(10), ...
                    '1: Lens transformation;', char(10),...
                    '2: Propagation a distance z;',char(10),...
                    '3: From object focal plane to sensor plane ', char(10),...
                    '4: From sensor plane to object focal plane']);
        end
    else
    %% 4D LF transformation  
        [Ny, Nx, Ntty, Nttx, Nc] = size(LF);
        
        pttx = ptt(2);
        ptty = ptt(1);
        
        x = ((1:Nx)-Nx/2)*pxy;    % x axis of the LF
        y = ((1:Ny)-Ny/2)*pxy;    % y axis of the LF
        Lx = Nx*pxy;
        Ly = Ny*pxy;
        
        ttx = ((1:Nttx)-Nttx/2)*pttx;    %  tan(theta) axis of the LF
        tty = ((1:Ntty)-Ntty/2)*ptty;    %  tan(theta) axis of the LF
        Lttx = Nttx*pttx;
        Ltty = Ntty*ptty;                % length of tan(theta)
        
        switch trans_type
            case 1
                % For lens transformation, where the focal length of lens is fz
                traMat = [  1      0;
                          -1/fz    1];
                for iy = 1:Ny
                    tty_prime = y(iy).*traMat(2,1) + tty;
                    itty_prime = round((tty_prime + Ltty/2)/ptty);
                    
                    itty_prime(itty_prime<1)  = 1;
                    itty_prime(itty_prime>Ntty) = Ntty;
                    
                    [~, itty_]= find(abs(tty_prime) <= Ltty/2);
                    
                    for ix = 1:Nx
                        ttx_prime = x(ix).*traMat(2,1) + ttx;                       
                        ittx_prime = round((ttx_prime + Lttx/2)/pttx);                        
                        
                        ittx_prime(ittx_prime<1) = 1;
                        ittx_prime(ittx_prime>Nttx) = Nttx;
                        
                        [~, ittx_]= find(abs(ttx_prime) <= Lttx/2);                        
                        
                        LF_new(iy, ix, itty_prime(itty_), ittx_prime(ittx_), :)...
                            = LF(iy, ix, itty_, ittx_, :);
                    end
                end
            case 2
                % For propagation with a distance fz
                traMat = [1    fz; ...
                          0    1];
                for itty = 1:Ntty
                    y_prime = y + traMat(1,2)*tty(itty);
                    iy_prime = round((y_prime + Ly/2)/pxy);
                    
                    iy_prime(iy_prime<1) = 1;
                    iy_prime(iy_prime>Ny) = Ny;
                    
                    [~, iy_] = find(abs(y_prime) <= Ly/2);
                    
                    for ittx = 1:Nttx
                        x_prime = x + traMat(1,2)*ttx(ittx);
                        ix_prime = round((x_prime + Lx/2)/pxy);                        
                        
                        ix_prime(ix_prime<1) = 1;
                        ix_prime(ix_prime>Nx) = Nx;
                        
                        [~, ix_] = find(abs(x_prime)<= Lx/2);
                        
                        LF_new(iy_prime(iy_), ix_prime(ix_), itty, ittx, :)...
                            = LF(iy_, ix_, itty, ittx, :);
                    end
                end
            case 3
                % From object focal plane to the sensor plane, fz = [zoc zs],
                % where zoc is the DOF of the object, zs is the distance from
                % the lens to the sensor                
                traMat = [-fz(2)/fz(1)       0; ...
                          -1/fz(1)-1/fz(2)   -fz(1)/fz(2)];  % T(zs)*T(f)*T(zoc)
                
                % Need to be optimized
                for itty = 1:Ntty
                    tty_val = tty(itty);
                    
                    for iy = 1:Ny
                        y_val = y(iy);
                        
                        y_prime = traMat(1, 1)*y_val + traMat(1, 2)*tty_val;
                        tty_prime = traMat(2, 1)*y_val + traMat(2, 2)*tty_val;
                        
                        iy_prime = round((y_prime + Ly/2)/pxy);
                        itty_prime = round((tty_prime + Ltty/2)/ptty);
                        
                        for ittx = 1:Nttx
                            ttx_val = ttx(ittx);
                            
                            for ix = 1:Nx
                                x_val = x(ix);
                                
                                x_prime = traMat(1,1)*x_val + traMat(1,2)*ttx_val;
                                ttx_prime = traMat(2,1)*x_val + traMat(2,2)*ttx_val;
                                
                                ix_prime = round((x_prime + Lx/2)/pxy);
                                ittx_prime = round((ttx_prime + Lttx/2)/pttx);
                                
                                if(ix_prime > 0) && (ix_prime <= Nx) && (ittx_prime >0) && (ittx_prime <= Nttx) &&  ...
                                        (iy_prime > 0) && (iy_prime <= Ny) && (itty_prime >0) && (itty_prime <= Ntty)
                                    LF_new(iy_prime, ix_prime, itty_prime, ittx_prime, :) = LF(iy, ix, itty, ittx, :);
                                end
                            end
                        end
                        
                    end
                end
                
            case 4
                % From the sensor plane to the object focal plane, fz = [zoc zs],
                traMat = [-fz(1)/fz(2)            0; ...
                          1/fz(1)+1/fz(2)   -fz(2)/fz(1)];     %% the inverse matrix of case 3
                
                % Need to be optimized
                for itty = 1:Ntty
                    tty_val = tty(itty);
                    
                    for iy = 1:Ny
                        y_val = y(iy);
                        
                        y_prime = traMat(1, 1)*y_val + traMat(1, 2)*tty_val;
                        tty_prime = traMat(2, 1)*y_val + traMat(2, 2)*tty_val;
                        
                        iy_prime = round((y_prime + Ly/2)/pxy);
                        itty_prime = round((tty_prime + Ltty/2)/ptty);
                        
                        for ittx = 1:Nttx
                            ttx_val = ttx(ittx);
                            
                            for ix = 1:Nx
                                x_val = x(ix);
                                
                                x_prime = traMat(1, 1)*x_val + traMat(1, 2)*ttx_val;
                                ttx_prime = traMat(2, 1)*x_val + traMat(2, 2)*ttx_val;
                                
                                ix_prime = round((x_prime + Lx/2)/pxy);
                                ittx_prime = round((ttx_prime + Lttx/2)/pttx);
                                
                                if(ix_prime > 0) && (ix_prime <= Nx) && (ittx_prime > 0) && (ittx_prime <= Nttx) &&  ...
                                        (iy_prime > 0) && (iy_prime <= Ny) && (itty_prime >0) && (itty_prime <= Ntty)
                                    LF_new(iy_prime, ix_prime, itty_prime, ittx_prime, :) = LF(iy, ix, itty, ittx, :);
                                end
                            end
                        end
                        
                    end
                end
                
            otherwise                
                disp(['LF type should be:', char(10), ...
                    '1: Lens transformation;', char(10),...
                    '2: Propagation a distance z;',char(10),...
                    '3: From object focal plane to sensor plane ', char(10),...
                    '4: From sensor plane to object focal plane']);
        end
    end
end    % end of the lf_prop function