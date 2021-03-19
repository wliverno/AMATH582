%% 2D DOS
clear all, close all, clc;
load DNADOS.mat;
load gammaCoeffs.mat;
N = 9;

temp = zeros(N, length(DOS));
for j = 1:N
     range = [j (N*2)+1-j];   
     temp(j, :) = temp(j, :) + sum(DOSBlock(range , :));

end
DOSBlock = flip(temp, 1); clear temp;

figure(1), subplot(1,2,1);
contourf(1:size(DOSBlock, 1), Energy, log(DOSBlock'), 'edgecolor', 'none');
title('Density of States along DNA Strand');
xlabel('Base-Pair Number (left to right)');
ylabel('Energy (eV)');
colormap hot;
caxis([-15 10]);
axis([1 9 -6 -5.5])
%set(gca, 'FontSize', 30, 'LineWidth', 2); %<- Plot properties
xticks(1:size(DOSBlock, 1))
% ylim([-4.8 -4.5])
% caxis([-4 0])
%title([num2str(num_basepairs) '-mer'])

subplot(1,6,4), plot(gammaLcoeffs, E), axis([0 1 -6 -5.5]), title('\Gamma_L Coeffs');
subplot(1,6,5), plot(gammaRcoeffs, E), axis([0 1 -6 -5.5]), title('\Gamma_R Coeffs');
