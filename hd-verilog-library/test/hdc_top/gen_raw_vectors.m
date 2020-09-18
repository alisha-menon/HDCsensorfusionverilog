close all
clear
clc

load('hdc_test_trials.mat');

f_vector = fopen('top_raw_vectors.txt','w');
f_output = fopen('correct_outputs.txt','w');

mode_width = 2;
label_width = 5;
feat_window = 50;

mode_predict = 0;
mode_train = 1;
mode_update = 3;

% training data initial context
data = t;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    mode(501:end-500) = mode_train;
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

% prediction data initial context
data = p1init;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

% prediction data new context
data = p1new;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

% update data new context
data = u;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    mode(501:end-500) = mode_update;
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

% prediction data initial context
data = p2init;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

% prediction data new context
data = p2new;
for g = 1:13
    trial = data(g).raw;
    idx = 3001:8000;
    trial = trial(idx,:);
    mode = mode_predict.*zeros(size(idx));
    
    label = g-1;
    count = 0;
    for i = 1:length(mode)
        vector = [dec2bin(mode(i),mode_width) dec2bin(label,label_width) reshape(dec2bin(trial(i,:),15)',1,64*15) '\n'];
        fprintf(f_vector,vector);
        count = count + 1;
        if count == feat_window
            count = 0;
            if mode(i) == mode_predict
                fprintf(f_output, [num2str(label) '\n']);
            end
        end
    end
end

fclose(f_vector);
fclose(f_output);