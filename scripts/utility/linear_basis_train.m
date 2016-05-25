function [ U ] = linear_basis_train(files,l)
%LINEAR_BASIS Summary of this function goes here
%   Detailed explanation goes here

num_species = size(files,1);
k = 50;
U = zeros(l,k,num_species);


for i=1:num_species
    
    x = [];
    for j=1:size(files,2)
        x = [x;read_audio(files{i,j})];
    end
    %x=x(1:100000);
    
    [~,S,Vi] = svd(patches(x,l),'econ');
    U(:,:,i) = Vi(:,1:k);
end


end