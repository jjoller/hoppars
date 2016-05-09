

function test_results()

tic;

for i=1:4
    seed = 1; % used this (seed can be any integer) to do any time the same run
    % seed = 'shuffle'; % use this to make any time a different run
    test_results_once(seed);
    movefile('results.mat',['results' num2str(i) '.mat']);
end

toc;

end

function test_results_once(seed)

rng(seed);

% generate Table 2 with original mat files from William
table_2_org = generateTable('.\orgMatFiles\data_variable.mat','.\orgMatFiles\data_fixed.mat',seed);

% generate Table 4 with original mat files from William
table_4_org = generateTable('.\orgMatFiles\data_variable_6.mat','.\orgMatFiles\data_fixed_6.mat',seed);

% generate the features for Table 2, i.e. using data in "enregistrements"
% (the seven species present in field recordings)
[~] = main_variable_length('..\data\enregistrements', 'data_variable.mat');
[~] = main_fixed_frame('..\data\enregistrements', 'data_fixed.mat');
% generate Table 2 with the just generated mat files
table_2 = generateTable('data_variable.mat','data_fixed.mat',seed);

% generate the features for Table 4, i.e. using data in "enregistrements_6"
% (8 species with 6 files each)
[~] = main_variable_length('..\data\enregistrements_6', 'data_variable_6.mat');
[~] = main_fixed_frame('..\data\enregistrements_6', 'data_fixed_6.mat');
% generate Table 4 with the just generated mat files
table_4 = generateTable('data_variable_6.mat','data_fixed_6.mat',seed);

% save results
save('results.mat','table_2_org','table_4_org','table_2','table_4');

end
    
function table_x = generateTable(variableFeatures, fixedFeatures,seed)

% prepare the table
rowNames = {'All versus all';'Cross validation';'One versus all';};
varNames = {'Fixed_frame';'Variable_length';};
table_x = cell2table(cell(3,2), 'RowNames',rowNames','VariableNames',varNames);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use the features already calculated using "main_variable_length.m"
% Variable frame length
featureFile = variableFeatures;

% We use three methods: allVsAll, crosVad, oneVsAll. For each we
% calculate the accuracy 4 times and average

% allVsAll
acc = [];
for i = 1:4
    acc = [acc; allVsAll(featureFile,seed)];
end

table_x.Variable_length{'All versus all'} = mean(acc);
disp(table_x);

%crosVad
acc = [];
for i = 1:4
    acc = [acc; crosVad(featureFile,seed)];
end

table_x.Variable_length{'Cross validation'} = mean(acc);
disp(table_x);

%oneVsAll
acc = [];
for i = 1:4
    acc = [acc; oneVsAll(featureFile,seed)];
end
table_x.Variable_length{'One versus all'} = mean(acc);
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
