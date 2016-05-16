base_dir = 'william.26.01.2016/data/enregistrements_6/';
files = species_files(base_dir);
size(files)

n = 255;

correct = 0;
total = 0;

% perform one-vs-all cross validation

U = linear_basis_train(files,n);

for i=1:size(files,1)
    truelabel = i;
    for j=1:size(files,2)
        
        % the test file
        to_predict = files{i,j};
    
        fprintf('classify %s\n',to_predict);
        predictedlabel = linear_basis_classify(to_predict,U);
        fprintf('predicted label: %d, true label: %d\n',predictedlabel,truelabel);
        
        hit = predictedlabel == truelabel;
        correct = correct + hit;
        total = total + 1;
    end
end
correct
total

