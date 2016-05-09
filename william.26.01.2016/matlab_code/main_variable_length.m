function [FeaturesTable] = main_variable_length(base_dir, output_dir)
%
% 16.11.15

%% cleanup
%close; clc

%% Initialise constants
showPlot = 0;
id = 1;
FeaturesTable = [];

% % decide for which case to generate the features
% % table 2: data in "enregistrements" i.e. the seven species present in field recordings
% % table 4: data in "enregistrements_6" i.e. 8 species whit 6 files each
% table2 = false;
% table4 = true;
% if (table2)
%     base_dir = '..\data\enregistrements';
%     output_dir = 'data_variable.mat';
% end
% if (table4)
%     base_dir = '..\data\enregistrements_6';
%     output_dir = 'data_variable_6.mat';
% end


%% get all the data directories, to treat each of the files they contain
data_dirs = dir(fullfile(base_dir,'\data_*'));
data_dirs = {data_dirs.name};
% for each data directory
dirsNumber = length(data_dirs);

for d = 1:dirsNumber
    speciesName = strrep(data_dirs{d},'data_','');
    data_dir = fullfile(base_dir, data_dirs{d});
    % get the filename within the directory
    fileName = dir(fullfile(data_dir,'*.wav'));
    fileName = {fileName.name};
    fileNumber = length(fileName);
    
    for f = 1:fileNumber
        audioFile = fullfile(data_dir, fileName{f});
        fprintf('directory %d/%d (%s): file %d/%d \n', d, dirsNumber, speciesName, f, fileNumber);
        
        %% Features extraction
        display('     computing features...');
        features = activity_detector(audioFile, showPlot);
        display('     features extracted');
        [m,~] = size(features);
        species = categorical(repmat({speciesName},m,1));
        ID = id*ones(m,1);
        id = id + 1;
        FeaturesTable = [FeaturesTable; table(features(:,1), features(:,2), features(:,3:end), species, ID, 'VariableNames', {'TimeDuration' 'F0'  'LFCC'  'speciesName' 'ID'})];
    end
end

save(output_dir, 'FeaturesTable');

clear label features showPlot output_dir speciesName audioFile base_dir d; 
clear data_dir data_dirs dirsNumber f fileName fileNumber m ID id species;

display(' # finish !');

end


