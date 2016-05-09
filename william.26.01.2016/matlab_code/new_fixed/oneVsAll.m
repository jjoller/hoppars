
function acc = oneVsAll(featureFile, seed)

%%
%clear; clc;
rng(seed);

%----------GMM-PARAMETERS--------------------------------------------------
cov_type = 'diagonal'; % shape of the covariance matrix : 'diagonal' or 'full'
K = 8; % number of Gaussians, if K = 1 -> Naive Bayes...
rr = 1e-5; % Regularize parameter
%--------------------------------------------------------------------------

%% load the features if they exist, otherwise generate them
%load data_fixed.mat;
load(featureFile);

%% Get the features, the labels and the file ID
% if the data come from the folder "new_fixed" :
features = table2array(selectedFeatures(:,3:end-2));
label = selectedFeatures.speciesName;
id = selectedFeatures.fileId;

% if the data come from the folder "fixed_&_variable" :
% features = table2array(FeaturesTable(:,1:end-2));
% label = FeaturesTable.speciesName;
% id = FeaturesTable.ID;

%% get the species and the individuals
species = unique(label);
individuals = unique(id);

%% one versus all: train the species model for all but one individual, which is used for testing

for i = 1:length(individuals);
   
    fprintf('- individual %d/%d \n', i, length(individuals));
    
    testIndex = (id == individuals(i)); trainIndex = ~testIndex;
    trainSet = features(trainIndex, :);
    testSet = features(testIndex, :);
    trainLabel = label(trainIndex, :);
    testLabel = label(testIndex, :);
    
    % train the model for each of the species
    for s = 1:length(species)
                
        model{s} = fitgmdist(trainSet(trainLabel==species(s), :), K, ...
            'CovarianceType', cov_type, ...
            'Regularize', rr, ...
            'Start', 'plus');
        
    end
    
    % testing comparing the test
    for s = 1:length(species)
        prob(s) = sum(log(pdf(model{s}, testSet(:,:))));
    end

    [~, predictedLabel(i)]=max(prob);
    actualLabel(i) = find(species==unique(testLabel));

end

acc = 100*length(find([predictedLabel'==actualLabel']))/length(actualLabel);
%disp(acc);

%disp(confusionmat(actualLabel,predictedLabel));

end
