

function test_results()

tic;

% generate the fixed frame-length features, 
% using the new fixed frame-length code in "\new_fixed" 

% generate the file "data_fixed.mat" in directory "\new_fixed" containing
% the features for Table 2, i.e. using data in "enregistrements"
% (the seven species present in field recordings)
data_dir = '..\..\data\all_dieStimmenDerHeuschrecken';
selectedSpecies = 'selectedSpecies.mat';
outputFile = 'data_fixed.mat';
calculateFeatures(data_dir, selectedSpecies, outputFile);


% generate the file "data_fixed_6.mat" in directory "\new_fixed" containing
% the features for Table 4, i.e. using data in "enregistrements_6"
% (8 species with 6 files each)
data_dir = '..\..\data\all_dieStimmenDerHeuschrecken';
selectedSpecies = 'selectedSpecies_6.mat';
outputFile = 'data_fixed_6.mat';
calculateFeatures(data_dir, selectedSpecies, outputFile);


for i=1:1
    %seed = 1; % used this (seed can be any integer) to do any time the same run
    seed = 'shuffle'; % use this to make any time a different run
    test_results_once(seed);
    movefile('results.mat',['results' num2str(i) '.mat']);
end

toc;

end

function test_results_once(seed)

rng(seed);

% generate Table 2 
table_2 = generateTable('data_fixed.mat',seed);

% generate Table 4 
table_4 = generateTable('data_fixed_6.mat',seed);

% save results
save('results.mat','table_2','table_4');

end
    
function table_x = generateTable(fixedFeatures,seed)

% prepare the table
rowNames = {'All versus all';'Cross validation';'One versus all';};
varNames = {'Fixed_frame';'Variable_length';};
table_x = cell2table(cell(3,2), 'RowNames',rowNames','VariableNames',varNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The is neo new code to calculate the varable frame-length features
table_x.Variable_length{'All versus all'} = NaN;
table_x.Variable_length{'Cross validation'} = NaN;
table_x.Variable_length{'One versus all'} = NaN;
disp(table_x);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use the features already calculated using "main_fixed_frame.m"
% Fixed frame length
featureFile = fixedFeatures;

% We use three methods: allVsAll, crosVad, oneVsAll. For each we
% calculate the accuracy 4 times and average

% allVsAll
acc = [];
for i = 1:4
    acc = [acc; allVsAll(featureFile,seed)];
end

table_x.Fixed_frame{'All versus all'} = mean(acc);
disp(table_x);

%crosVad
acc = [];
for i = 1:4
    acc = [acc; crosVad(featureFile,seed)];
end

table_x.Fixed_frame{'Cross validation'} = mean(acc);
disp(table_x);

%oneVsAll
acc = [];
for i = 1:4
    acc = [acc; oneVsAll(featureFile,seed)];
end
table_x.Fixed_frame{'One versus all'} = mean(acc);
disp(table_x);

end
