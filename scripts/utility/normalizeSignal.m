function [ normed ] = normalizeSignal( x )
%NORMALIZESIGNAL Scale signal that the average is 0 and the signal fits
%into the -1 +1 range

m = mean(x);
x = x - m;
range = max(abs(x));
normed = x ./ range;

end

