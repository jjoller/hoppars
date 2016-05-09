%%
clear; clc;
%rng('shuffle');

%----------GMM-PARAMETERS--------------------------------------------------
cov_type = 'diagonal'; % shape of the covariance matrix : 'diagonal' or 'full'
K = 8; % number of Gaussians, if K = 1 -> Naive Bayes...
rr = 1e-5; % Regularize parameter
%--------------------------------------------------------------------------

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

%% all versus all: train the species model with all individuals, then test with each individual

% train the model for each of the species using all data
trainSet = features(:, :);
trainLabel = label(:, :);

for s = 1:length(species)
    model{s} = fitgmdist(trainSet(trainLabel==species(s), :), K, ...
        'CovarianceType', cov_type, ...
        'Regularize', rr, ...
        'Start', 'plus');
end




for i = 1:length(individuals);
    
    testIndex = (id == individuals(i));
    testSet = features(testIndex, :);
    testLabel = label(testIndex, :);
       
    % testing
    for s = 1:length(species)
        prob(s) = sum(log(pdf(model{s}, testSet(:,:))));
    end

    [~, predictedLabel(i)]=max(prob);
    actualLabel(i) = find(species==unique(testLabel));

end

acc = 100*length(find([predictedLabel'==actualLabel']))/length(actualLabel);
disp(acc);

disp(confusionmat(actualLabel,predictedLabel));


