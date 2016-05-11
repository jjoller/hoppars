function x = concatenate_audio( files, skip)
%CONCATENATE_AUDIO Summary of this function goes here
%   Detailed explanation goes here

x = [];
for i=1:numel(files)
    file = files{i};
    if strcmp(file,skip) == 0
        x = [x;read_audio(files{1})];
    end
end


end

