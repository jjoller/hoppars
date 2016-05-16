function [class] = ksvd_classify(x,U)
%KSVD_CLASSIFY classify using a dictionary per species.

n = size(U,1);
X = patches(x,n)';

residuals = zeros(size(U,3),1);
for i=1:size(U,3)
    
    for j=1:size(X,2)
        
        % reconstruct the signal
        [~,r] = wmpalg('BMP',double(X(:,j)),double(U(:,:,i)));
        
        % update the residual
        residuals(i) = residuals(i) + norm(r);
    end
    
end

[~,class] = min(residuals);


residuals

