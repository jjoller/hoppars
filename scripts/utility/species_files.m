function [ species ] = species_files( base_dir )
%SPECIES_FILES Summary of this function goes here
%   Detailed explanation goes here


%base_dir = 'william.26.01.2016/data/enregistrements_6/';
data_dirs = dir(fullfile(base_dir,'/data_*'));
data_dirs = {data_dirs.name};
dirsNumber = length(data_dirs);

species = cell(dirsNumber,6);

for d = 1:dirsNumber
    speciesName = strrep(data_dirs{d},'data_','');
    
    data_dir = fullfile(base_dir, data_dirs{d});
    % get the filename within the directory
    fileName = dir(fullfile(data_dir,'*.wav'));
    fileName = {fileName.name};
    fileNumber = length(fileName);

    for f = 1:fileNumber
        species{d,f} = fullfile(data_dir, fileName{f});
    end
    
end

end

