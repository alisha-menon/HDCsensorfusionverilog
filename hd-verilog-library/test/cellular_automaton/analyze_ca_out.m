close all
clear
clc

fid = fopen('ca_out.txt');

vectors = [];
d = fgetl(fid);
while ischar(d)
    vectors = [vectors; d-'0'];
    d = fgetl(fid);
end

fclose(fid);

set1 = vectors(4:67,:);
set2 = vectors(70:133,:);

if isequal(set1, set2)
    disp('Sequence is repeatable');
else
    disp('Sequence did not repeat!');
end

distances = zeros(64,64);
for i = 1:64
    for j = 1:64
        distances(i,j) = dot(set1(i,:), set1(j,:))/(norm(set1(i,:)) * norm(set1(j,:)));
    end
end
        
imagesc(distances)
caxis([0 1])