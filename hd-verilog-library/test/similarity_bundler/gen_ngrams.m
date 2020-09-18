close all
clear
clc

load('exp_1.mat');

idx = find(gestures == 112);
idx = reshape(idx,80,5);
idx = idx(1:76,:);
idx = reshape(idx,76*5,1);

fid = fopen('similarity_bundler_vectors.txt','w');
x = {'0','1'};
hypervectors = double(hypervectors > 0);
hidx = randperm(10000);
hidx = sort(hidx(1:1000));
for i = 1:length(idx)
    hstring =char(x(hypervectors(idx(i),:)+1));
    fprintf(fid,[hstring(hidx)' '\n']);
end
    
