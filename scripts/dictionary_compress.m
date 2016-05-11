

base_dir = 'william.26.01.2016/data/enregistrements_6/';
data_dirs = dir(fullfile(base_dir,'/data_*'));
data_dirs = {data_dirs.name};
dirsNumber = length(data_dirs);

for d = 1:dirsNumber
    
    speciesName = strrep(data_dirs{d},'data_',''); % TODO use to put "class" labels to the features
    data_dir = fullfile(base_dir, data_dirs{d});
    % get the filename within the directory
    fileName = dir(fullfile(data_dir,'*.wav'));
    fileName = {fileName.name};
    fileNumber = length(fileName);
    
    x = [];
    for f = 1:fileNumber
        
        wav_file = fullfile(data_dir, fileName{f});
      
        
        fprintf('directory %d/%d (%s): file %d/%d \n', d, dirsNumber, speciesName, f, fileNumber);
        
        [speech, fs] = audioread( wav_file );
        % convert to 44100 sampling frequency
        if (fs ~= 44100)
            fprintf('resample from %d to 44100 Hz\n', fs);
            speech = resample(speech,44100,fs);
            fs = 44100;
        end
        % take the first channel
        speech = speech(:,1);
        
        speech = normalizeSignal(speech);
        x = [x;speech];
        
    end
    
    
    
end



%[y,Fs] = audioread('william.26.01.2016/data/enregistrements_6/data_cantans/018 _1_S.wav');




