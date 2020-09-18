%% Reset workspace
close all
clear
clc
addpath(genpath('.'))

%% Load data
load('./info/info.mat')
exp = {};

% sub = [1 2 3 4 5]; % subjects to test
sub = 2;

for s = sub
    exp{s} = load_subject_data(s);
end

allData = exp{2}{1};

features = get_features_hw(allData, 32, @mav, 32);
