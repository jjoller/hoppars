
function [T,S] = getSelectedSpecies(data_dir,selectedSpecies) 

[selectedFiles, sumry] = readDatabase(data_dir);
% .mat which conatins the name the species that need to be extracted
load(selectedSpecies)
cats = ww(:,1);
wwt = table(cats);

S = innerjoin(sumry,wwt);

TselectedFiles = cell2table(selectedFiles,...
    'VariableNames',{'fileName' 'cats' 'fileId' 'speciesId'});

T = innerjoin(TselectedFiles,wwt);
end