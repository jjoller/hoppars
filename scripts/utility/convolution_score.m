function score = convolution_score( file, dictionaries )
%CONVOLUTION_CLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

    x = read_audio(file);
    n = numel(x);
    y = fft(x);
    
    y = repmat(y,1,size(dictionaries,2));
    
    % pad with zeros
    dictionaries(n,1) = 0;
    
    fprintf('fft');
    d = fft(dictionaries);
    fprintf('fft done');
    
    f = y .* d;
    
    fprintf('ifft');
    f = ifft(f);
    fprintf('ifft done');
    
    score = norm(f);
    
end

