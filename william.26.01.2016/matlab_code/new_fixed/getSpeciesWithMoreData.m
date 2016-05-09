
function [T,S,database5] = getSpeciesWithMoreData(data_dir) 

% data_dir = '..\..\data\all_dieStimmenDerHeuschrecken';
% [T,S,database5] = getSpeciesWithMoreData(data_dir);

[selectedFiles, sumry] = readDatabase(data_dir);

% select the species tha have more than 6 files (no need to load from
% selectedSpecies_6.mat)
wwt = sumry(sumry.count >=6,1);

S = innerjoin(sumry,wwt);

TselectedFiles = cell2table(selectedFiles,...
    'VariableNames',{'fileName' 'cats' 'fileId' 'speciesId'});

T = innerjoin(TselectedFiles,wwt);

% reduce the numbers of files to N=6
N=6;
database6 = table(); % contains the final table with 5 files per species
% for each species with more than 6 files
for i = 1:height(wwt)
    si = innerjoin(TselectedFiles,wwt(i,1));
    vv = randperm(height(si));
    vv = vv(1:N);
    database6 = [database6; si(vv,:)];
end

% reduce the numbers of files to N=5
N=5;
database5 = table(); % contains the final table with 5 files per species
% for each species with more than 6 files
for i = 1:height(wwt)
    si = innerjoin(TselectedFiles,wwt(i,1));
    vv = randperm(height(si));
    vv = vv(1:N);
    database5 = [database5; si(vv,:)];
end

% reduce the numbers of files to N=4
N=4;
database4 = table(); % contains the final table with 5 files per species
% for each species with more than 6 files
for i = 1:height(wwt)
    si = innerjoin(TselectedFiles,wwt(i,1));
    vv = randperm(height(si));
    vv = vv(1:N);
    database4 = [database4; si(vv,:)];
end


end