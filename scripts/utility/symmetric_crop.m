function [ f ] = symmetric_crop( y )
%SYMMETRIC_CROP Summary of this function goes here
%   Detailed explanation goes here

    n2 = floor(numel(y)/2)+1;
    f = y(1:n2);

end

