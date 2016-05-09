
close; clc;

% audioFile = '\\esplabnas1.epfl.ch\orthoptera\enregistrement_divers\field_sounds\F-1061.WAV';
% true_label = 'parallelus';

% audioFile = '\\esplabnas1.epfl.ch\orthoptera\enregistrement_divers\trap\intro.wav';
% true_label = 'I Feel Fine';

base_dir = '..\data\field_sounds';

% data for the training
load .\orgMatFiles\data_fixed.mat; method = 'fixed'; 
%load .\orgMatFiles\data_variable.mat; method = 'variable';

%----------PARAMETERS-TO-TUNE----------------------------------------------
threshold = 0.4; % threshold to take the decision
%--------------------------------------------------------------------------

%----------GMM-PARAMETERS--------------------------------------------------
gaus_type = 'diagonal'; % shape of the covariance matrix : 'diagonal' or 'full'
K = 8; % number of Gaussians, if K = 1 -> Naive Bayes...(but Naive Bayes seems to be diagonal matrix)
rr = 1e-4; % Regularize parameter
rep = 1; % number of time to reapeat EM algorithm  using a new set of initial values
%--------------------------------------------------------------------------

%-----------VARIABLE-INITIALIZATION----------------------------------------
features_train = table2array(FeaturesTable(:,1:end-2));
label_train = FeaturesTable.speciesName;
ID = FeaturesTable.ID;
species = unique(label_train); % conatins the name of the species
species_nb = length(species); % number of different species
predicted_label = cell(1, 1); % prediction of the individual (files)
gmm_model = cell(species_nb, 1); % GMM model
%--------------------------------------------------------------------------

fileName = dir(fullfile(base_dir,'*.wav'));
fileName = {fileName.name};
fileNumber = length(fileName);
acc = zeros(fileNumber, 1);

%% Training
% Create a GMM model for each class
for s = 1:species_nb;
    gmm_model{s} = fitgmdist(features_train(label_train==species(s), :), K, 'CovType', gaus_type, 'Replicates', rep, 'Regularize', rr);
end

%% For each file
for f = 1:fileNumber
    [C] = strsplit(fileName{f}, {'_',});
    true_label = C{1};
    wav_file = fullfile(base_dir, fileName{f});
    fprintf('file %d/%d : %s \n', f, fileNumber, fileName{f});
    %% Features extraction for the test file
    if strcmp(method, 'variable')
        features = activity_detector(wav_file, 0);
    elseif strcmp(method, 'fixed')
        [speech, fs] = audioread(wav_file);
        % convert to 44100 sampling frequency
        if (fs ~= 44100)
            speech = resample(speech,44100,fs);
            fs = 44100;
        end
        % take the first channel
        speech = speech(:,1);
        % mean removal (dc-offset, hum ...). TODO: consider a high-pass filter as in Aurora standard
        speech = (speech - mean(speech));
        % Normalize the range of the signal in [-1,1]
        speech = speech / max(abs(speech));
        [LFCC, F0] = lfcc_fixed(speech, fs, 100, 10, 0.97, @hamming, [100 22000], 218, 24, 0 );
        [n, m] = size(LFCC);
        features = zeros(n, m);
        features(:, 1) = F0;
        features(:, 2:end) = LFCC(:, 2:end);
    else
        error('# error : wrong method name for features extraction !\n');
    end
    
    %% calculate propability / testing
    [n, m] = size(features);
    p = zeros(n, species_nb); % probability for each features vector
    for s = 1:species_nb;
        p(:,s) = log(pdf(gmm_model{s}, features));
    end
    
    %% prediction
    % look for the maximum value for each features vector
    [~, I] = max(p, [], 2);
    % count the number of occurence for each species
    bincounts = histc(I',1:species_nb);
    % normalize to have % value
    bincounts = bincounts / length(features);
    % take a decision
    [p_max, I] = max(bincounts);
    if(p_max > threshold) % if the max prob is higher than the treshold, we can accept this prediction
        predicted_label = cellstr(species(I));
    else % else, we don't know which species it is
        predicted_label = cellstr('unknown');
    end
    if strcmp(predicted_label, true_label)
        correct = 'yes'; acc(f) = 1;
    else
        correct = 'no';
    end
    fprintf('-----------------------------\n');
    fprintf('- CorrectRate : %f %% \n', 100*p_max);
    fprintf('- True Label  : %s\n', char(true_label));
    fprintf('- Predicted   : %s\n', char(predicted_label));
    fprintf('- Correct ?   : %s \n', correct);
    fprintf('-----------------------------\n\n');
    
end

[y, Fs] = audioread('\\esplabnas1.epfl.ch\orthoptera\enregistrement_divers\trap\intro.wav');
sound(y(1:2*Fs), Fs);

fprintf('-----------------------------\n');
fprintf('- Accuracy : %f %% \n', 100*mean(acc));
fprintf('-----------------------------\n\n');



