function [ patches ] = patches( x,l )
%PATCHES Summary of this function goes here
%   Detailed explanation goes here

% add zero padding
x(l * ceil(numel(x)/l)) = 0;

% reshape
patches = reshape(x,[numel(x)/l,l]);

end

