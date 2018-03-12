function [f, w] = compareBoxes(hist,hist2,T2,kernel,H,W)
w = zeros(H,W);
f = 0;
for i = 1:H
    for j = 1:W
        w(i,j) = sqrt(hist(T2(i,j)+1) / hist2(T2(i,j)+1));
        f = f+w(i,j)*kernel(i,j);
    end
end

f = f/(H*W); 