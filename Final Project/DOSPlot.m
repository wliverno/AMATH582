%% 2D DOS
clear all, close all, clc;
load DNADOS.mat
N = 9;

for i = 1:N
    group{i} = [i (N*2)+1-i];
end

temp = zeros(length(group), length(DOS));
for j = 1:length(group)
     range = [group{j}(1) group{j}(2)];   
     temp(j, :) = temp(j, :) + sum(DOSBlock(range , :));

end
DOSBlock = temp; clear temp;

figure(1);
contourf(1:size(DOSBlock, 1), Energy, log(DOSBlock'), 'edgecolor', 'none');
title('Density of States along DNA Strand');
xlabel('Base-Pairs');
ylabel('Energy (eV)');
colormap hot;
colorbar;
caxis([-15 10]);
%set(gca, 'FontSize', 30, 'LineWidth', 2); %<- Plot properties
xticks(1:size(DOSBlock, 1))
% ylim([-4.8 -4.5])
% caxis([-4 0])
%title([num2str(num_basepairs) '-mer'])
