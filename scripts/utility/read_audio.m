function speech = read_audio( wav_file )
    [speech, fs] = audioread( wav_file );
    % convert to 44100 sampling frequency
    if (fs ~= 44100)
       fprintf('resample from %d to 44100 Hz\n', fs);
       speech = resample(speech,44100,fs);
    end
    % take the first channel
    speech = speech(:,1);
    speech = normalizeSignal(speech);
end

