function [ frames ] = frames( x, l, n)
%FRAMES Extract frames of length l from a signal

% add zero padding and reshape
all = patches(x,l);

% keep n frames with the highest energy
[~,ind] = sort(var(all),'descend');
frames = all(:,ind(1:n));

end

