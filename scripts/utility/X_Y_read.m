function [ X,Y ] = X_Y_read( files, n)
%X_Y_READ Summary of this function goes here
%   Detailed explanation goes here

X = [];
y = [];
for i=1:size(files,1)
    label = i;
    for j=1:size(files,2)
        x = read_audio(files{i,j});
        
        Xi = patches(x,n);
        yi = ones(size(Xi,1),1) * label;
        
        X = [X;Xi];
        y = [y;yi];
    end
    
end

Y = zeros(size(X,1),size(files,2));
for i=1:numel(y)
    Y(i,y(i)) = 1;
end

end

