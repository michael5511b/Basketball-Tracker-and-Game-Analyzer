function [x1, y1] = expandTemplate(j, x0, y0, W, H, movW, movH)
if j ==1
    x1 = x0-W;
    y1 = y0-H;
elseif j ==2
    x1 = x0;
    y1 = y0-H;
elseif j ==3
    x1 = x0+W;
    y1 = y0-H;
elseif j ==4
    x1 = x0-W;
    y1 = y0;
elseif j == 5
    x1 = x0 + W;
    y1 = y0;
elseif j ==6
    x1 = x0 - W;
    y1 = y0 + H;
elseif j == 7
    x1 = x0;
    y1 = y0 + H;
elseif j == 8
    x1 = x0 + W;
    y1 = y0 + H;
end

%% handle any negative or out of bounds
if y1 <= 0
    y1 = 1;
end
if y1+H >= movH
    y1 = movH - H -1;
end
if x1 <= 0;
    x1 = 1;
end
if x1 + W >= movW
    x1 = movW - W - 1; 
end
