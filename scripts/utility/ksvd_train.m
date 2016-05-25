function [U] = ksvd_train(files,n)

num_species = size(files,1);

% number of frames
k = 50;
U = zeros(n,k,num_species);

% train a dictionary for each species
for i=1:num_species
    
    % read the files from one species and concatenate the sound files
    x = [];
    for j=1:size(files,2)
        x = [x;read_audio(files{i,j})];
    end
    
    % just for speeding up the calculation
    %x = x(1:500000);
    
    X = patches(x,n)';
    
    param = struct('K',k,'preserveDCAtom',0,'InitializationMethod','DataElements','numIteration',300,'errorFlag',0,'L',1);
    
    % train the dictionary
    Ui = KSVD(X,param);
    
    U(:,:,i)=Ui;
end




end