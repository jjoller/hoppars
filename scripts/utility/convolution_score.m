function score = convolution_score( file, dictionaries )
%CONVOLUTION_CLASSIFIER Summary of this function goes here
%   Detailed explanation goes here

    x = read_audio(file);
    if numel(x) > 100000
        x = x(1:100000);
    end
    
    input_norm = norm(x)/numel(x);
    n = numel(x);
    y = fft(x);
   
    response_norm = 0;
    for i=1:size(dictionaries,2)
        d = dictionaries(:,i);
        % pad with zeros
        d(n)=0;
        d = fft(d);
        f = y .* d;
        response_norm = response_norm + norm(f);
    end
    
    response_norm = response_norm/numel(f);
    score = response_norm/input_norm;
    
end

