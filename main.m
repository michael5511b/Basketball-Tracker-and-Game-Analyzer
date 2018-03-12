clear; clc; close all;
%% Mean Shift Tracking -rewrite
warning('off', 'Images:initSize:adjustingMag');
str = 'miss_01_a';
%% For movie: import
if ~exist(strcat(str, '.mat'), 'file')
    fprintf('Reading Video file... ');
    tic
    path = strcat('videos/',str,'.mp4');
    movie = VideoReader(path);
    movH = movie.Height;
    movW = movie.Width;
    nFrames = movie.NumberOfFrames;
    mov(1:nFrames) = struct('color', zeros(movH, movW, 3, 'uint8'), 'colormap', []) ;
    for i = 1: nFrames
        mov(i).color = read(movie, i);
    end
    save(strcat(str,'.mat'), '-v7.3')
else
    fprintf ('Loading Video File... ');
    tic
    load(strcat(str,'.mat'));
    toc
end

%% Select Patch
f1 = figure(1);
imshow(mov(1).color); title('Select an object to track '); 
fprintf('Please highlight an object to track \n');
rect = getrect;


x0 = round(rect(1)); y0 = round(rect(2));
W = round(rect(3)); H = round(rect(4));
T = mov(1).color(y0:y0+H-1, x0:x0 + W - 1,:);
rectangle('Position', [x0, y0, W, H], 'LineWidth', 2, 'EdgeColor', 'g');
close(f1);

f1 = figure(1);
imshow(mov(1).color); title('Select the rim');
rect = getrect;
rimX = round(rect(1)); rimY = round(rect(2));
rimW = round(rect(3)); rimH = round(rect(4));
rectangle('Position', [rimX, rimY, rimW, rimH], 'LineWidth', 2, 'EdgeColor', 'g');

figure(2); imshow(T); 
%% create Kernel Density Estimation (Parzen Window)
%There are a few different Kernels we can use 
%We are using the normal (gaussian) Kernel because the shape fo the weight
%seems to make the most sense for a ball
R = 1;
kernel = zeros(H,W); 
sigmaH = (R*H/2)/3;
sigmaW = (R*W/2)/3;
for i = 1:H
    for j = 1:W
        kernel(i,j) = exp(-1/2*((i - 1/2*H)^2 / sigmaH^2+...
            (j-1/2*W)^2/sigmaW^2));
    end
end
[gx, gy] = gradient(-kernel); 

figure(3); mesh(kernel); title('Gaussian Kernel'); 
%% indexing from rgb2ind
[indexedImage, colorMap] = rgb2ind(mov(1).color,65536);
LMap = length(colorMap)+1; 
indT = rgb2ind(T,colorMap);

%% Create Histogram
hist = createHist(indT, LMap, kernel, H,W);

%% Similarity Function
f = [];

%% Play video
figure(5);
f_lowThresh = 0.04;
f_highThresh = 0.2;
max_it = 5;

expansion = 0; 
for i = 1:nFrames
    Iclr = mov(i).color;
    Iind = rgb2ind(mov(i).color, colorMap);

    %% check if it is near the hoop
    
    
    %% first frame
    if i == 1
        [x,y,f] = MS_Tracking(hist, Iind, LMap,...
            movH, movW, f_highThresh, max_it, x0, y0, H,W,...
            kernel, gx, gy);
    %% if we are still detecting the ball   
    elseif f > f_lowThresh 
        
        [x,y,f] = MS_Tracking(hist, Iind, LMap,...
            movH, movW, f_highThresh, max_it, x0, y0, H,W,...
            kernel, gx, gy);
%         Tclr = mov(i).color(y0:y0 + H - 1, x0:x0 + W - 1,:);
%         Tclr = rgb2gray(Tclr);
%         Tclr = imadjust(Tclr);
%         
%         %% finding circles
%         radius = round(mean([W, H]));
%         
%         bin = imbinarize(Tclr, 'adaptive', 'ForegroundPolarity', 'dark');
%         bin = bwareaopen(bin,15);
%         figure(6)
%         imshow(bin)
%         [centers, radii, metric] = imfindcircles(bin, [20 30], 'ObjectPolarity', 'dark','Sensitivity', 0.95);
%         viscircles(centers, radii, 'EdgeColor', 'g');
%         
%         figure(5)
        f 
        
        
        if f < f_lowThresh
            expansion = 1;
        else 
            expansion = 0;
        end
    else
        expansion = 1;
    end
    
    
    %% after 
    if expansion == 1
        figure(4); hold on;
        imshow(Iclr);
        rectangle('Position', [x0,y0,W,H], 'EdgeColor', 'r', 'LineWidth', 2);
        %% Start Expansion Function
        %% Find the centroid of template
        %% Make 4 different templates around that point
        
        for j =1:8 %each corner
            [x1, y1] = expandTemplate(j, x0, y0, W, H, movW, movH); 
            
            rectangle('Position', [x1,y1, W,H], 'EdgeColor', 'g', 'LineWidth', 2);
            [newX,newY,f] = MS_Tracking(hist, Iind, LMap,...
                movH, movW, f_highThresh, max_it, x1, y1, H,W,...
                kernel, gx, gy);
            f
            if f > f_lowThresh
                x = newX;
                y = newY;
                expansion = 0;
                break;
            end
        end
     end
    
        
    cx = round((x0 + W/2));
    cy = round((y0 + H/2));
    
    nearHoop = 0; 
    if cx < rimX + rimW && cx > rimX
        if cy < rimY + rimH && cy > rimY
            nearHoop = 1; 
            fCat = []; 
            locCat = []; 
        end
    end
    %% if it's near the hoop, do extra searching
    if nearHoop == 1
        figure(4); hold on;
        imshow(Iclr);
        rectangle('Position', [x0,y0,W,H], 'EdgeColor', 'r', 'LineWidth', 2);
        for j = 1:8
            [x1, y1] = expandTemplate(j, x, y, W, H, movW, movH);
            rectangle('Position', [x1,y1, W,H], 'EdgeColor', 'g', 'LineWidth', 2);
            [newX,newY,f] = MS_Tracking(hist, Iind, LMap,...
                movH, movW, f_highThresh, max_it, x1, y1, H,W,...
                kernel, gx, gy);
            rectangle('Position', [x1,y1, W,H], 'EdgeColor', 'g', 'LineWidth', 2);
            fCat = cat(1, fCat, f);
            locCat = cat(1, locCat, [newX,newY]); 
        end
        [~, index] = max(fCat);
        x = locCat(index, 1);
        y = locCat(index, 2); 
    end
    
    x0 = x;
    y0 = y; 
    imshow(mov(i).color);
    rectangle('Position', [x, y, W, H], 'LineWidth', 2, 'EdgeColor', 'g');
    pause(0.1); 
end







