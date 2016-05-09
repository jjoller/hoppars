
%%
clear; clc;

%rng('shuffle');

% GMM-PARAMETERS
cov_type = 'diagonal'; % shape of the covariance matrix : 'diagonal' or 'full'
K = 8; % number of Gaussians, if K = 1 -> Naive Bayes...
rr = 1e-5; % Regularize parameter

% CROSS-VALIDATION PARAMETERS
nFolds = 5; % number of folds

%% load the features if they exist, otherwise generate them
load data_fixed.mat;

%% Resample the set to have equal a priori training probabilities

disp('Number of frames per species, before resampling:')
summary(selectedFeatures.speciesName);

cats = categories(selectedFeatures.speciesName);
count = countcats(selectedFeatures.speciesName);
minCount = min(count);

resampledFeatures = [];
for s = 1:length(cats)
    ind = randperm(count(s));
    ind = ind(1:minCount);
    tab =selectedFeatures(selectedFeatures.speciesName == cats(s),:);
    tab = tab(ind,:);
    tab = sortrows(tab,'fileId','ascend');
    resampledFeatures = [resampledFeatures; tab];
end

disp('Number of frames per species, after resampling:')
summary(resampledFeatures.speciesName);
clear selectedFeatures;

%% Get the features, the labels and the file ID
% if the data come from the folder "new_fixed" :
% features = table2array(selectedFeatures(:,3:end-2));
% label = selectedFeatures.speciesName;
% id = selectedFeatures.fileId;

% if the data come from the folder "fixed_&_variable" :
features = table2array(FeaturesTable(:,1:end-2));
label = FeaturesTable.speciesName;
id = FeaturesTable.ID;

%% get the species and the individuals
species = unique(label);
individuals = unique(id);

%%
% 5-fold cross validation
[n, m] = size(features);
indices = crossvalind('Kfold', n, nFolds);

for fold= 1:nFolds
    fprintf('- fold %d/%d \n', fold, nFolds);
    testIndex = (indices == fold); trainIndex = ~testIndex;
    trainSet = features(trainIndex, :);
    testSet = features(testIndex, :);
    trainLabel = label(trainIndex, :);
    testLabel = label(testIndex, :);
    trainId = id(trainIndex, :);
    testId = id(testIndex, :);

    % train the model for each of the species
    for s = 1:length(species)
        
        model{s} = fitgmdist(trainSet(trainLabel==species(s), :), K, ...
            'CovarianceType', cov_type, ...
            'Regularize', rr, ...
            'Start', 'plus');
        
    end
    
    % Test by individual, using the testing data
    for ind = 1:length(individuals);
        %disp(individuals(ind));
        % testing (present the testing data of the individual to each model)
        for s = 1:length(species)
            prob(s) = sum(log(pdf(model{s}, testSet(testId==individuals(ind),:))));
        end
        [~, predictedLabel(ind)] = max(prob);
        actualLabel(ind) = find(species==unique(testLabel(testId==individuals(ind))));
        
    end
    
    
    acc(fold) = 100*length(find([predictedLabel'==actualLabel']))/length(actualLabel);
    disp(acc(fold));
    
    disp(confusionmat(actualLabel,predictedLabel));

end

fprintf('- total \n');
disp(mean(acc));




