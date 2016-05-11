
base_dir = 'william.26.01.2016/data/enregistrements_6/';
files = species_files(base_dir);
size(files)

framelength = 1000;
num_frames = 100;

correct = 0;

% perform one-vs-all cross validation
for i=1:size(files,1)
    truelabel = i;
    for j=1:size(files,2)
        
        % the test file
        to_predict = files{i,j};
    
        % train the model on all but one file
        maxscore = -Inf;
        lable = -1;
        for label = 1:size(files,1)
            
            % do not train on the test file
            x = concatenate_audio(files(i,:), to_predict);
            
            size(x)
            
            f = frames(x,framelength,num_frames);
            score = convolution_score(to_predict,f)
            if score > maxscore
                maxscore = score;
                predictedlabel = label;
            end
        end
        
        if predictedlabel == truelabel
            correct = correct+1;
        end
    end  
    
end


