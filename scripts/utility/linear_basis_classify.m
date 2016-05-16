function [ class ] = linear_basis_classify( file, U )
%LINEAR_BASIS_CLASSIFY Summary of this function goes here
%   Detailed explanation goes here

x = read_audio(file);
X = patches(x,size(U,1));
minscore = Inf;
for i=1:size(U,3)
    Y = X * U(:,:,i);
    Xrec = Y * U(:,:,i)';
    Diff = Xrec - X;
    score = norm(Diff);
    if score < minscore
        minscore = score;
        class = i;
    end  
end

end
