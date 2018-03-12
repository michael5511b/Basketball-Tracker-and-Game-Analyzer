%% Mean Shift Tracking
function [x,y,f] = MS_Tracking(hist, Iind, LMap,...
            movH, movW, f_highThresh, max_it, x0, y0, H,W,...
            kernel, gx, gy)
y = y0;
x = x0;
T2 = Iind(y:y+H-1, x:x+W-1);

hist2 = createHist(T2,LMap, kernel,H,W);
[f,w] = compareBoxes(hist,hist2,T2,kernel,H,W);
for iteration = 1:max_it
    if f > f_highThresh
        break;
    end
    
    num_x = 0; 
    num_y = 0;
    den = 0;
    for i = 1:H
        for j = 1:W
            num_x = num_x + i*w(i,j)*gx(i,j);
            num_y = num_y + j*w(i,j)*gy(i,j);
            den = den + w(i,j)*norm([gx(i,j), gy(i,j)]);
        end
    end
    %% Calculate how much to displace the new box by 
    if den ~= 0
        dx = round(num_x/den);
        dy = round(num_y/den);
        y = y+dy;
        x = x+dx;
    end
    if y <= 0
        y = 1;
    end
    if y+H >= movH
        y = movH - H -1;
    end
    if x <= 0;
        x = 1;
    end
    if x + W >= movW
        x = movW - W - 1;
    end
   T2 = Iind(y:y+H-1, x:x+W-1);
   hist2 = createHist(T2, LMap, kernel, H, W);
   [f, w] = compareBoxes(hist,hist2,T2,kernel,H,W);
end
