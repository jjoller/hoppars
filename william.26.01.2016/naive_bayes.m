
close; clc;

test = 1;
folds = 5;
load .\matlab_code\orgMatFiles\data_variable.mat;
label = FeaturesTable.speciesName;
features = table2array(FeaturesTable(:,1:end-2));
acc = zeros(folds,1);
result = zeros(test,1);

for j = 1:test

    indices = crossvalind('Kfold',label,folds);
    for i = 1:folds
        fprintf('test %d/%d of run %d... ', i, folds, j);

        testIndex = (indices == i); trainIndex = ~testIndex;

        trainSet = features(trainIndex, :);
        testSet = features(testIndex, :);
        trainLabel = label(trainIndex, :);
        testLabel = label(testIndex, :);

        % train the model
        Mdl = fitcnb(trainSet, trainLabel);

        %test the model
        predictedLabel = predict(Mdl, testSet);

        %cMat = confusionmat(testLabel,predictedLabel);
        %accuracy = sum(diag(cMat))/sum(sum(cMat));
        cp = classperf(cellstr(testLabel),cellstr(predictedLabel));
        acc(i) = cp.CorrectRate;

        fprintf('%f %% \n', 100*acc(i));
    end

    fprintf('- mean of run %d -> %f %% \n', j, 100*mean(acc));
    result(j) = mean(acc);
end

fprintf('\n# final mean of %d runs -> %f %% \n', j, 100*mean(result));

