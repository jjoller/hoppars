function [FeaturesTable] = main_fixed_frame(base_dir, output_dir)
%
% 16.11.15

% Clean-up MATLAB's environment
%close; clc;

% decide for which case to generate the features
% table 2: data in "enregistrements" i.e. the seven species present in field recordings
% table 4: data in "enregistrements_6" i.e. 8 species whit 6 files each
% table2 = false;
% table4 = true;
% if (table2)
%     base_dir = '..\data\enregistrements';
%     output_dir = 'data_fixed.mat';
% end
% if (table4)
%     base_dir = '..\data\enregistrements_6';
%     output_dir = 'data_fixed_6.mat';
% end

%% get all the data directories, to treat each of the files they contain
data_dirs = dir(fullfile(base_dir,'\data_*'));
data_dirs = {data_dirs.name};
% for each data directory
dirsNumber = length(data_dirs);

%% Define variables
id = 1;
Tw = 100;               % analysis frame duration (ms)
Ts = 10;                % analysis frame shift (ms)
alpha = 0.97;           % preemphasis coefficient
M = 218;                 % number of filterbank channels
C = 23;                 % number of cepstral coefficients
%L = 22;                 % cepstral sine lifter parameter
LF = 100;               % lower frequency limit (Hz)
HF = 22000;              % upper frequency limit (Hz)

%%
FeaturesTable = [];
for d = 1:dirsNumber
    
    speciesName = strrep(data_dirs{d},'data_',''); % TODO use to put "class" labels to the features
    data_dir = fullfile(base_dir, data_dirs{d});
    % get the filename within the directory
    fileName = dir(fullfile(data_dir,'*.wav'));
    fileName = {fileName.name};
    fileNumber = length(fileName);
    
    for f = 1:fileNumber
        wav_file = fullfile(data_dir, fileName{f});
        fprintf('directory %d/%d (%s): file %d/%d \n', d, dirsNumber, speciesName, f, fileNumber);
        
        %% Read speech samples and sampling rate from file
        [speech, fs] = audioread( wav_file );
        % convert to 44100 sampling frequency
        if (fs ~= 44100)
            speech = resample(speech,44100,fs);
            fs = 44100;
        end
        % take the first channel
        speech = speech(:,1);
        
        %% Pre-processing
        % mean removal (dc-offset, hum ...). TODO: consider a high-pass filter as in Aurora standard
        speech = (speech - mean(speech));
        
        % consider using a notch filter as in the aurora standard, instead
        % of the mean removal
        % y (n) = x (n) - x (n -1) + 0,999 * y (n -1)
        % b = [1 -1]; a = [1 - 0,999];  freqz(b,a,[],44100);
        % speech = filter(b, a, speech);
                
        % Normalize the range of the signal in [-1,1]
        speech = speech / max(abs(speech));
                
        %% Feature extraction (feature vectors as columns)
        fprintf('\tcomputing features...\n');
        [LFCC, F0] = lfcc_fixed(speech, fs, Tw, Ts, alpha, @hamming, [LF HF], M, C+1, 0 );
        [m,~] = size(LFCC);
        %TODO: add the calculated energy, leave the energy term, and later decide if the features is usefull or not.
        LFCC = LFCC(:,2:end); % remove the energy term. 
        % mean removal
        LFCC = LFCC - mean(mean(LFCC));
        species = categorical(repmat({speciesName},m,1));
        ID = id*ones(m,1);
        id = id + 1;
        FeaturesTable = [FeaturesTable; table(F0, LFCC, species, ID, 'VariableNames', {'F0'  'LFCC'  'speciesName' 'ID'})];      
        
    end
end

% summary(FeaturesTable);
save(output_dir, 'FeaturesTable');

clear label features showPlot output_dir speciesName audioFile base_dir; 
clear data_dir data_dirs dirsNumber f fileName fileNumber m alpha C d F0;
clear fs HF LF LFCC M species speech Ts Tw wav_file ID id d species;

display(' # finish !');

end

function [] = plotFeatures(frames, Ts, fs, speech, FBEs, M, C, MFCCs)

% Generate data needed for plotting
[ Nw, NF ] = size( frames );                % frame length and number of frames
time_frames = [0:NF-1]*Ts*0.001+0.5*Nw/fs;  % time vector (s) for frames
time = [ 0:length(speech)-1 ]/fs;           % time vector (s) for signal samples
logFBEs = 20*log10( FBEs );                 % compute log FBEs for plotting
logFBEs_floor = max(logFBEs(:))-50;         % get logFBE floor 50 dB below max
logFBEs( logFBEs<logFBEs_floor ) = logFBEs_floor; % limit logFBE dynamic range


% Generate plots
figure('Position', [30 30 800 600], 'PaperPositionMode', 'auto', ...
    'color', 'w', 'PaperOrientation', 'landscape', 'Visible', 'on' );

subplot( 311 );
plot( time, speech, 'k' );
xlim( [ min(time_frames) max(time_frames) ] );
xlabel( 'Time (s)' );
ylabel( 'Amplitude' );
title( 'Speech waveform');

subplot( 312 );
imagesc( time_frames, [1:M], logFBEs );
axis( 'xy' );
xlim( [ min(time_frames) max(time_frames) ] );
xlabel( 'Time (s)' );
ylabel( 'Channel index' );
title( 'Log (mel) filterbank energies');

subplot( 313 );
imagesc( time_frames, [1:C], MFCCs(2:end,:) ); % HTK's TARGETKIND: MFCC
%imagesc( time_frames, [1:C+1], MFCCs );       % HTK's TARGETKIND: MFCC_0
axis( 'xy' );
xlim( [ min(time_frames) max(time_frames) ] );
xlabel( 'Time (s)' );
ylabel( 'Cepstrum index' );
title( 'Mel frequency cepstrum' );

% Set color map to grayscale
colormap( 1-colormap('gray') );

%Print figure to pdf and png files
% print('-dpdf', sprintf('%s.pdf', mfilename));
% print('-dpng', sprintf('%s.png', mfilename));

end

