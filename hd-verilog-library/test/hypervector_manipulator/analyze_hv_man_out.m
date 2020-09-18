close all
clear
clc

fid = fopen('hv_man_out.txt');

vectors = [];
manipulators = [];
while (~feof(fid))
    d = fgetl(fid);
    if ischar(d)
        if length(d)==80
            manipulators = [manipulators; d-'0'];
        else
            vectors = [vectors; d-'0'];
        end
    end
end

hv_in = vectors(1:2:end,:);
hv_out = vectors(2:2:end,:);
sim = hv_in == hv_out;