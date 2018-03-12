function hist = createHist(T, LMap, kernel, H,W)
hist = zeros(LMap,1);
color = linspace(1, LMap, LMap);
for i = 1:W
    for j = 1:H
        hist(T(j,i)+1) = hist(T(j,i)+1) + kernel(j,i);
    end
end
% ---Normalize the Histogram ----
C = 1/sum(sum(kernel));
hist = C.*hist;
end
