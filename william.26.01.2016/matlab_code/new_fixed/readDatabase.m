
function [selectedFiles, sumry] = readDatabase(data_dir)

% read the excel databasefiles with the names of all the recordings
[~,txt] = xlsread(fullfile('\Datentabelle.xls'));

% get the filenames of all the recordings (remove the hedares line)
filenames = txt(2:end,2);

% test that all the files are in the directory "all"
filenames2 = dir (fullfile(data_dir, '*.wav'));
filenames2 = {filenames2.name}';
if (~isequal(sort(filenames),sort(filenames2)))
    error('The filenames do not correspond to the files in the directory');
end


% for all the files, test if the files exists in the directory "all"
% for ii=1:length(filenames)
%     name = filenames{ii};
%     if (exist(fullfile('.\all',name)) ~= 2)
%         error('The file does not exists');
%     end
% end

% now selects the files that are :
% not a portion used to produce a picture: starts with 'Abb.' followed by a space
% not another sound : starts with a letter in the part before the space
% not a variation of type (1x003b and 4x087b) : ends with a letter in the part before the space
% not an 'oscillogram' : filename contains '_Os_' in the part after the first space
% not recorded with UltraSound : filename contains '_US_' in the part after the first space
% contain only a standard song: there is an '_S' before '.wav' in the second part
% Note, there are 8 files with standard song plus other song:
    % 030 Pholidoptera aptera_4_S und A.wav
    % 045 Gryllus bimaculatus_2_S und W.wav
    % 068 Chrysochraon dispar_5_S und R.wav
    % 076 Stenobothrus stigmaticus_2_S und G.wav
    % 076 Stenobothrus stigmaticus_3_S und G.wav
    % 086 Chorthippus vagans_4_S und R.wav
    % 086 Chorthippus vagans_5_S und R.wav
    % 093 Chorthippus dorsatus_7_S und R.wav
% does not have and extra comment: the second part spit into 4 parts
% Note, there are 12 files with an extra comment:
    % 015 Ruspolia nitidula_5_Distanz_S.wav
    % 018 Tettigonia cantans_2_komisch_S.wav
    % 029 Metrioptera fedtschenkoi minor_3_Konzert_S.wav
    % 032 Pholidoptera fallax_4_Konzert_S.wav
    % 044 Gryllus campestris_9_Konzert_S.wav
    % 045 Gryllus bimaculatus_3_Konzert_S.wav
    % 068 Chrysochraon dispar_4_Vergleich_S.wav
    % 074 Stenobothrus lineatus_8_Fluggeraeusch_S.wav
    % 082 Myrmeleotettix maculatus_3_Vergleich_S.wav
    % 091 Chorthippus brunneus_7_Vergleich_S.wav
    % 093 Chorthippus dorsatus_5_Vergleich_S.wav
    % 096 Euchorthippus declivus_6_Vergleich_S.wav

selectedFiles = cell(length(filenames),1);
jj = 1;
for ii=1:length(filenames)
    name = filenames{ii};
    [token, remain] = strtok(name); % split into parts using the first space
    [C] = strsplit(remain,{'_','.'},'CollapseDelimiters',true); % split the second part with delimiters '_' or '.'
    
    % select files that:
    select = all(isstrprop(token, 'digit')) ... % have all digits in the first part (do not start or end with a letter)
        && isempty(strfind(remain,'_Os_'))  ... % do not contain '_Os_' in the second part
        && isempty(strfind(remain,'_US_'))  ... % do not contain '_US_' in the second part
        && ~isempty(strfind(remain,'_S.wav'))  ... % has only a standard song
        && (length(C) == 4)  ... % does not have an additional comment
        ;
    
    if (select)
        %disp(name);
        selectedFiles{jj,1} = name;
        selectedFiles{jj,2} = strtrim(C{1});
        selectedFiles{jj,3} = str2double(C{2});
        selectedFiles{jj,4} = str2double(token);
        jj = jj + 1;
    end
end

selectedFiles(jj:end,:)=[];

% at the end we have a N*4 cell array "selectedFiles" with:
% N: number of selected files
% column 1: filename of each of the selected files
% column 2: species of each of the selected files
% column 3: instance (original instance number) of each of the selected files
% column 4: species number (original unique species number) for each of the selected files

%summary(categorical(selectedFiles(:,2)));
count = countcats(categorical(selectedFiles(:,2)));
cats = categories(categorical(selectedFiles(:,2)));
sumry = table(cats,count);
sumry = sortrows(sumry,'count','descend');
