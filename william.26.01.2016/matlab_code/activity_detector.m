
function [features] = activity_detector(audioFile, showPlot)
%   [features] = activity_detector(audioFile, showPlot)
% Variable length features extraction. Shearch on the folder data_dir for 
% all the files and return the name and the number of the files. 
%   Arguments :
%       audioFile : name of the file to compute
%       showPlot : 1 or 0 to show or not the plot
%   Outputs :
%       features : contain the features
% William Ducret : 12.10.2015

%% Define variables
alpha = 0.97;           % preemphasis coefficient
M = 218;                 % number of filterbank channels
C = 23;                 % number of cepstral coefficients
%L = 22;                 % cepstral sine lifter parameter
LF = 100;               % lower frequency limit (Hz)
HF = 22000;              % upper frequency limit (Hz)
frame_max = 1.5;    % time max in [s] of a frame


%% Aquisition
%Fs : Frequ. sampling, y = data
[y, Fs] = audioread(audioFile);
% convert to 44100 sampling frequency
if (Fs ~= 44100)
    y = resample(y,44100,Fs);
    Fs = 44100;
end
% separate the two channels
x = y(:,1);

%% Pre-processing
% mean removal (dc-offset, hum ...).
x = (x - mean(x));

% Normalize the range of the signal in [-1,1]
x = x / max(abs(x));

% consider pre-emphasis
% filter design with the app from matlab, for configuration, see 'highpass_filter.PNG'
plotResponse = false;
x = highpass_filter(x,plotResponse); % TODO: do before normalisation ?

%% buffering and Energy
% K = nb d'échantillons dans un frame, L = overlapping 
K = 100;
E = smooth(x.^2,K);

%% Threshold
% estimate the noise energy over the noise only periods
E_noise_estim = smooth(x.^2,Fs/10);
%th = min(E5) + .01*(max(E5)-min(E5));
th_noise = min(E_noise_estim) + .02*mean(E_noise_estim);

sil = E_noise_estim < th_noise;
if(isempty(sil))
    E_noise = 1e-5;
else
    E_noise = mean(E_noise_estim(sil));
end

th_high = 20*E_noise;
th_low = 4*E_noise;

state = double_thresh(E,th_high,th_low);

%% Activity
[~, ~, pos0, len0] = extractLength(state);
% we're looking for every 0 state shorter than 'activityFactor' samples.
activityFactor = 20;
sil = len0 < activityFactor;
state2 = zeros(1,length(state));
for i = find(sil)
    for j = 0:len0(i)-1
        state2(pos0(i)+j) = 1;
    end
end

state = state | state2;
[pos1, len1] = extractLength(state);
% detection if a state is bigger than 'frame_max'
sil = len1 > frame_max*Fs;
while sum(sil) % while there is something bigger than 'frame_max*Fs' 
    for i = find(sil) % find all the occurance
        state(pos1(i)+frame_max*Fs) = 0; % go at the occurance + frame_max to put activity to 0,
        % like this the activity will be frame_max*Fs long for this frame
    end
    % re-compute the len1 to look after other frame bigger than 'frame_max*Fs'
    [pos1, len1] = extractLength(state);
    sil = len1 > frame_max*Fs;
end

%% Processing
% 2 is for the time duration and main frequency
features = zeros(length(pos1),2 + C);

for i = 1:length(pos1)
    % Time duration
    features(i, 1) = len1(i)/Fs;
    % LFCC and dominant frequence
    [LFCC, f0] = lfcc_variable(x(pos1(i):pos1(i)+len1(i)-1), Fs, alpha, @hamming, [LF HF], M, C+1, 0 );
    % mean removal
    LFCC = LFCC - mean(mean(LFCC));
    features(i, 2) = f0;
    % we don't take the first LFCC
    features(i, 3:end) = LFCC(2:C+1);
end

%% Displaying
if (showPlot)
    t = 0:1/Fs:(length(x)-1)/Fs;
    figure;
    hold on
    plot(t, x, 'c', t, E *max(abs(x))/max(E), 'b')
    plot([0 (length(x)-1)/Fs],[th_high th_high], 'k')
    plot([0 (length(x)-1)/Fs],[th_low th_low], 'r')
    plot(t, 0.5*state, 'm')
    legend('Signal', 'Energy', 'High Threshold', 'Low Threshold', 'Activity Detector')
    xlabel('time [s]');
    ylabel('amplitutde');
    hold off
end

end

