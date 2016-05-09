function [] = calculateFeatures(data_dir, selectedSpecies, outputFile)

% initialize the random number generator
%rng('shuffle');

%% get all the files
% a directory containing all the 965 .wav files from the dvd of C. Roesti
%data_dir = 'E:\Die Stimmen der Heuschrecken\Tonaufnahmen\all';
% data_dir = '..\..\data\all_dieStimmenDerHeuschrecken';
% selectedSpecies = 'selectedSpecies.mat';
% outputFile = 'data_fixed.mat';
[T, S] = getSelectedSpecies(data_dir,selectedSpecies);
fileName = T.fileName;
speciesName = T.cats;
fileNumber = length(fileName);

%% Define parameters as in (Ganchev 2007) - fixed-length feature exatrction

Tw = 100;               % analysis frame duration (ms)
Ts = 10;                % analysis frame shift (ms)
M = 218;                 % number of filterbank channels
C = 23;                 % number of cepstral coefficients
LF = 100;               % lower frequency limit (Hz)
HF = 22000;              % upper frequency limit (Hz)
FS = 44100;             % all files are converted to FS = 44100
Nw = round( 1E-3*Tw*FS );    % frame duration (samples)
Ns = round( 1E-3*Ts*FS );    % frame shift (samples)

% Note: (Ganchev 2007) does not use pre-emphasis
alpha = 0.97;           % preemphasis coefficient

%% Extract the features, for each file

featureTable = [];

for f = 1:fileNumber
    
    wav_file = fullfile(data_dir, fileName{f});
    fprintf('file: %d of %d: %s\n',f, fileNumber, wav_file);
    
    %% Read speech samples and sampling rate from file
    [speech, fs] = audioread( wav_file );
    
    % find sequences of Tz = 1 ms of "zero" which may indicate that the file was edited
    % and this part added artificially. Remove those at the beginning and at the end,
    % no matter their length, and remove zero segments longer than 10 ms
    speech = findAndRemoveZeros(speech,fs);
    
    % convert to FS = 44100 sampling frequency
    if (fs ~= FS)
        speech = resample(speech,FS,fs);
        fs = FS;
    end
    
    % take the first channel
    speech = speech(:,1);
    
    %% Pre-processing
    
    % offset compensation by mean removal
    speech = speech - mean(speech);
    % TODO: consider using a notch filter as in the aurora standard, instead of the mean removal
    % y (n) = x (n) - x (n -1) + 0,999 * y (n -1)
    % which in matlab would be :
    % b = [1 -1]; a = [1 - 0,999];  freqz(b,a,[],FS);
    % speech = filter(b, a, speech);
    
    % Normalize the range of the signal in [-1,1]
    speech = speech / max(abs(speech));
    
    % Pre-emphasis is done in lfcc.m as first we should calculate the frame
    % energies logE and E
    % speech = filter( [1 -alpha], 1, speech ); % freqz([1 -alpha], 1,[],FS);
    
    %% Feature extraction (feature vectors as columns)
    
    fprintf('\tcomputing features...\n');
    
    [LFCC, F0, logE, E] = lfcc( speech, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, 0);
    
    % plot([LFCC(:,1) logE E]); grid; legend('C0','logE','E');
    
    % remove the energy term. TODO: leave it and decide later if this features is usefull or not
    LFCC = LFCC(:,2:end);
    
    % assemble the features into a feature vector
    [m,n] = size(LFCC);
    species = categorical(repmat({speciesName{f}},m,1));
    fileId = categorical(repmat(f,m,1));
    featureTable = [featureTable; table(logE, E, F0, LFCC, species, fileId, ...
        'VariableNames', {'logE' 'E' 'F0'  'LFCC'  'speciesName' 'fileId'})];
    
end



%% do frame selection based on energy as done in (Kinnunen 2010)

disp('Number of frames per species, before frame selection:')
summary(featureTable.speciesName);

% we do it file per file, as the max value and thus the threshold varies in
% each file
files = unique(featureTable.fileId);
selectedFeatures = [];
for f = 1:length(files)
    tab = featureTable(featureTable.fileId == files(f),:);
    [m,n] = size(tab);
    max1 = max(tab.E); % Maximum
    I = (tab.E > max1 - 30) & (tab.E > -55); % Indicator
    tab = tab(I, :);
    selectedFeatures = [selectedFeatures; tab];
end

disp('Number of frames per species, after frame selection:')
summary(selectedFeatures.speciesName);
clear featureTable;

%% do feature normalization on the selected features

% Cepstral mean subtraction on a per-file basis
% for each file, calculate the mean LFCC vector and subtract to the LFCC vectors
files = unique(selectedFeatures.fileId);
for f = 1:length(files)
    [m,n] = size(selectedFeatures(selectedFeatures.fileId == files(f),'LFCC'));
    meanLFCC =  mean(selectedFeatures{selectedFeatures.fileId == files(f),'LFCC'});
    meanLFCC = repmat(meanLFCC,m,1);
    selectedFeatures{selectedFeatures.fileId == files(f),'LFCC'} = ...
        selectedFeatures{selectedFeatures.fileId == files(f),'LFCC'} - meanLFCC;
end

% feature normalisation over the whole training set
% for all the training set calculate the mean and standard deviation of
% each feature and use it to normalize each feature
[m,n] = size(selectedFeatures(:,1:4));
meanAll = mean(selectedFeatures{:,1:4});
meanAll = repmat(meanAll,m,1);
stdAll = std(selectedFeatures{:,1:4});
stdAll = repmat(stdAll,m,1);
selectedFeatures{:, 1:4} = selectedFeatures{:, 1:4} - meanAll;
selectedFeatures{:, 1:4} = selectedFeatures{:, 1:4} ./ stdAll;


save(outputFile,'selectedFeatures');

%% Resample the set to have equal a priori training probabilities

% disp('Number of frames per species, before resampling:')
% summary(selectedFeatures.speciesName);
% 
% cats = categories(selectedFeatures.speciesName);
% count = countcats(selectedFeatures.speciesName);
% minCount = min(count);
% 
% resampledFeatures = [];
% for s = 1:length(cats)
%     ind = randperm(count(s));
%     ind = ind(1:minCount);
%     tab =selectedFeatures(selectedFeatures.speciesName == cats(s),:);
%     tab = tab(ind,:);
%     tab = sortrows(tab,'fileId','ascend');
%     resampledFeatures = [resampledFeatures; tab];
% end
% 
% disp('Number of frames per species, after resampling:')
% summary(resampledFeatures.speciesName);
% 
% save ganc2007FixedLength resampledFeatures;

end

%%
% find sequences of Tz = 1 ms of "zero" which may indicate that the file was edited
% and this part added artificially. Remove those at the beginning and at the end,
% no matter their length, and remove zero segments longer than 10 ms

function [speech] = findAndRemoveZeros(speech, fs)

ff = (speech == 0);
if (any(ff))
    [pos1, len1, pos0, len0] = extractLength(ff');
    ddd = [pos1' len1'];
    if (find(ddd(1,1) == 1))
        fprintf('removed %d ms of zeros at the beginning \n', 1000*ddd(1,2)/fs);
        speech(1:ddd(1,2)) = [];
    end
end

% find a remove zeros at the end
ff = (speech == 0);
if (any(ff))
    [pos1, len1, pos0, len0] = extractLength(ff');
    ddd = [pos1' len1'];
    if (length(speech) == (ddd(end,1)+ddd(end,2)-1))
        fprintf('removed %d ms of zeros at the end \n', 1000*ddd(end,2)/fs);
        speech(ddd(end,1):ddd(end,1)+ddd(end,2)-1) = [];
    end
end

% find and remove zero segments longer than 10 ms
Tz = 10*1e-3;
Nz = fix(Tz * fs);
ff = (speech == 0);
if (any(ff))
    [pos1, len1, pos0, len0] = extractLength(ff');
    ddd = [pos1' len1'];
    iii=find(ddd(:,2)>Nz);
    ddd=ddd(iii,:);
    for jj=1:length(ddd(:,1))
        speech(ddd(jj,1):ddd(jj,1)+ddd(jj,2)-1) = NaN;
        fprintf('removed %d ms of zeros in between \n', 1000*ddd(jj,2)/fs);
    end
    speech(isnan(speech)) = [];
end

ff = (speech == 0);
if (any(ff))
    [pos1, len1, pos0, len0] = extractLength(ff');
    if ~isempty(find(len1 >= Nz))
        error('there are still frames of >= 10 ms of zeros ');
    end
end

end

