close all, clear all, clc;

%Import Data
mats =dir('*_BP(E).mat');

gammaL = zeros(length(mats), 1);
gammaR = zeros(length(mats), 1);

E = load(mats(1).name).Energy;
n = length(mats)
T = zeros(length(E), length(mats));

homo= -4.7620;
lumo=-0.7347;

for i = 1:length(mats)
    fname = mats(i).name;
    T(:, i) = load(fname).T;
    gammas = regexp(fname, '_[0-9]+\.*[0-9]*_', 'match');
    gammaLS = cell2mat(gammas(1));
    gammaLS = gammaLS(2:end-1);
    gammaRS = cell2mat(gammas(2));
    gammaRS = gammaRS(2:end-1);
    gammaL(i) = str2double(gammaLS);
    gammaR(i) = str2double(gammaRS);
end
E = load(fname).Energy;

%Get singular modes/values
[U,S,V] = svd(T);

% Plot sigma values and first mode
figure(1);
subplot(1,3,1), plot(diag(S)/sum(diag(S)),'ko','Linewidth',2), axis([0 50 0 1]);
title('Relative Energy of Principle Components');
[GL, GR] = ndgrid(linspace(min(gammaL), max(gammaL), 100), linspace(min(gammaR), max(gammaR), 100));
VV = griddata(gammaL, gammaR, -V(:,1), GL, GR);
subplot(1,3,3), surfl(GL,GR,VV), colormap pink, shading interp;
set(gca, 'XScale', 'log'), set(gca, 'YScale', 'log'), set(gca, 'ZScale', 'log');
xlabel('\Gamma_L'), ylabel('\Gamma_R'), zlabel('PC coeff');
title('\Gamma values vs First PC Coefficient');
subplot(1,3,2), semilogy(E,-U(:,1),'Linewidth',2);
title('First Principle Component Graph');
xline(homo,'--r', 'HOMO','HandleVisibility','off');
xline(lumo,'--r', 'LUMO','HandleVisibility','off');
% subplot(2,2,4), plot(E,U(:,2)/max(abs(U(:,2))),'Linewidth',[2])
% xline(homo,'--r', 'HOMO','HandleVisibility','off');
% xline(lumo,'--r', 'LUMO','HandleVisibility','off');
drawnow;

%Use first 23 components as rank cutoff for PCA
rank = 23; 
Ur = U(:, 1:rank); Sr = S(1:rank, 1:rank); Vr = V(:, 1:rank);
Tr = Ur*Sr*Vr';

% Reconstruct tranmission graph using reduced mode
figure(2), subplot(1,2,1);
n_graph = 200
semilogy(E', T(:,n_graph), '-k', E', Tr(:, n_graph), '--k');
title(['Transmission Graph Reconstruction (\Gamma_L=', num2str(gammaL(n_graph)),' \Gamma_R=', num2str(gammaR(n_graph)),') Rank=', num2str(rank)])
xlabel('Energy (eV)')
axis([-6 0 1e-25 1e0])
legend('Original', 'Reconstruction');
xline(homo,'--r', 'HOMO','HandleVisibility','off');
xline(lumo,'--r', 'LUMO','HandleVisibility','off');


coeffsCompare = pinv(T')*gammaL;
subplot(1,2,2), semilogy(E', abs(coeffsCompare));
title('Generated pinv(A)*b Coefficients Without Log');
xlabel('Energy (eV)');
drawnow;

% Use log of transmission for Regression
LT = log10(T);

% % Use CVX to construct an L1-regression 
% [gammaLsort, gammaLind] = sort(gammaL);
% [gammaRsort, gammaRind] = sort(gammaR);
% L1 on GammaL/GammaR
% cvx_setup
% cvx_begin;
%   cvx_solver mosek
%   variable x1(rank); 
%   minimize( norm(x1,1) ); 
%   subject to
%       (T'*Ur)*x1 == gammaLsort;
% cvx_end;
% 
% cvx_begin;
%   cvx_solver mosek
%   variable x2(rank); 
%   minimize( norm(x2,1) ); 
%   subject to
%       (T'*Ur)*x2 == gammaRsort;
% cvx_end;
% x1 = Ur*x1;
% x2 = Ur*x2;

% Using built-in matlab A\b solver
x1_ls = LT'\gammaL;
x2_ls = LT'\gammaR;

% Using pinv to solve
x1_ps = pinv(LT')*gammaL;
x2_ps = pinv(LT')*gammaR;

% Using fminsearch with rank r principle components
[Ul,Sl,Vl] = svd(LT);
Ulr = Ul(:, 1:rank);
Slr = diag(Sl(1:rank, 1:rank));
opt = optimset('MaxFunEvals',10000);
funcL = @(x) sum(abs(LT'*Ulr*x - gammaL));
funcR = @(x) sum(abs(LT'*Ulr*x - gammaR));
x1f_pc=fminsearch(funcL,Slr, opt);
x2f_pc=fminsearch(funcR,Slr, opt);
x1f = Ulr*x1f_pc;
x2f = Ulr*x2f_pc;

% Using LASSO method with Lambda=1e-3
x1 = lasso(LT', gammaL, 'Lambda', 1e-3);
x2 = lasso(LT', gammaR, 'Lambda', 1e-3);

%% Plot comparison of each Method
figure(3);

subplot(2,4,1), plot(E, abs(x2)/max(abs(x2))), title('LASSO Regression'),  ylabel('\Gamma_R coeffs');
subplot(2,4,5), plot(E, abs(x1)/max(abs(x1))),  xlabel('Energies (eV)'), ylabel('\Gamma_L coeffs');
subplot(2,4,2), plot(E, abs(x2_ls)/max(abs(x2_ls))), title('A\b Regresson');
subplot(2,4,6), plot(E, abs(x1_ls)/max(abs(x1_ls))), xlabel('Energies (eV)');
subplot(2,4,3), plot(E, abs(x2_ps)/max(abs(x2_ps))), title('pinv(A)*b Regresson');
subplot(2,4,7), plot(E, abs(x1_ps)/max(abs(x1_ps))),  xlabel('Energies (eV)');
subplot(2,4,4), plot(E, abs(x2f)/max(abs(x2f))), title('L1 regression using 23 PC modes');
subplot(2,4,8), plot(E, abs(x1f)/max(abs(x1f))), xlabel('Energies (eV)');
drawnow;

%% Plot Residuals
figure(4);
clf
hold on
lassoRes = abs(x1'*LT- min(x1'*LT) - gammaL')./gammaL';
backslashRes = abs(x1_ls'*LT - gammaL')./gammaL';
pinvRes = abs(x1_ps'*LT - gammaL')./gammaL';
fminRes = abs(x1f'*LT - gammaL')./gammaL';
subplot(1,4,1), plot(gammaL', lassoRes, 'ko'), set(gca,'xscale', 'log');
axis([0.005 20 0 20]), title('LASSO Residuals'), xlabel('\Gamma_L'), ylabel('Residuals');
subplot(1,4,2), plot(gammaL', backslashRes, 'ko'), set(gca,'xscale', 'log');
axis([0.005 20 0 20]), title('A\b Residuals'), xlabel('\Gamma_L');
subplot(1,4,3),plot(gammaL', pinvRes, 'ko'), set(gca,'xscale', 'log');
axis([0.005 20 0 20]), title('pinv(A)*b Residuals'), xlabel('\Gamma_L');
subplot(1,4,4), plot(gammaL', fminRes, 'ko'), set(gca,'xscale', 'log');
axis([0.005 20 0 20]), title('L1 PC Residuals'), xlabel('\Gamma_L');


% Store Lasso Results
gammaLcoeffs = abs(x1)/max(abs(x1));
gammaRcoeffs = abs(x2)/max(abs(x2));
save('gammaCoeffs.mat', 'E', 'gammaLcoeffs', 'gammaRcoeffs');
