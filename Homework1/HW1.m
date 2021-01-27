clear all; close all; clc

load subdata.mat

%Build space and wavenumber grids
L=10;
n=64;
x2 = linspace(-L, L, n+1); x=x2(1:n);
y = x;
z = x;
k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);
[X,Y,Z] = meshgrid(x,y,z);
[Kx, Ky, Kz] = meshgrid(ks, ks, ks);
Uk = zeros(n,n,n);

%Extract timestep data and average FFT results
for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    M = max(abs(Un),[],'all');
    Uk = Uk + fftn(Un);
    % DEBUGGING PLOTS:
%     clf
%     isosurface(X,Y,Z,abs(Un)/M,0.5);
%     axis([-20 20 -20 20 -20 20]), grid on, drawnow
%     isosurface(Kx,Ky,Kz,abs(Uks)/max(abs(Uks(:))),0.5);
%     axis([-10 10 -10 10 -10 10]), grid on, drawnow
%     pause(0.2)
end

%Shift and scale FFT data
Uks = fftshift(Uk);
aveUks = abs(Uks)/max(abs(Uks(:)));

% DEBUGGING PLOTS:
% isosurface(Kx,Ky,Kz,aveUks,0.9);
% axis([-10 10 -10 10 -10 10]), grid on, drawnow

% Uks2 = Uks(:,:,39);
% PDF2 = abs(Uks2).^2/trapz(ks, trapz(ks, abs(Uks2).^2));
% PDF2 = PDF2.*(PDF2>0.01);
% PDF2 = PDF2/trapz(ks, trapz(ks, PDF2));
% Kx2 = X(:,:,1);
% Ky2 = Y(:,:,1);
% Uks2p = abs(Uks2)/max(abs(Uks2(:)));
% figure, contourf(Kx2,Ky2,PDF2)
% 
% trapz(ks, trapz(ks, PDF2))
% 
% kx2 = trapz(ks, trapz(ks, PDF2.*Kx2))
% ky2 = trapz(ks, trapz(ks, PDF2.*Ky2))

% Threshold for localization of operators
cutoff = 0.9;

% Find mean values of kx using averaged frequency amplitudes
kx = ExpVal(ks, aveUks, Kx, cutoff)
ky = ExpVal(ks, abs(Uks).^2, Ky, cutoff)
kz = ExpVal(ks, abs(Uks).^2, Kz, cutoff)

%A simple gaussian filter to apply in frequency domain
filter = ifftshift(exp(-0.1*((Kx - kx).^2 + (Ky - ky).^2 +(Kz - kz).^2)));
%isosurface(Kx,Ky,Kz,filter,0.9);

%Extract location at each time point using filtered data
subLoc = zeros(49, 3);
subLocNoF = zeros(49, 3);
for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    Uf = ifftn(filter.*fftn(Un));
    Ufn = abs(Uf)/max(abs(Uf(:)));
    xLoc = ExpVal(x, Ufn, X, cutoff);
    yLoc = ExpVal(y, Ufn, Y, cutoff);
    zLoc = ExpVal(z, Ufn, Z, cutoff);
    subLoc(j, :) = [xLoc yLoc zLoc];
    xLocNoF = ExpVal(x, Un, X, cutoff);
    yLocNoF = ExpVal(y, Un, Y, cutoff);
    zLocNoF = ExpVal(z, Un, Z, cutoff);
    subLocNoF(j, :) = [xLocNoF yLocNoF zLocNoF];
end

%Plot submarine trajectory, compare to unfiltered trajectorynb
figure;
plot3(subLoc(:, 1), subLoc(:, 2), subLoc(:, 3), '-k', subLocNoF(:, 1), subLocNoF(:, 2), subLocNoF(:, 3), '--r')
title('Submarine Trajectory')
legend('Gaussian Filter Applied', 'No Filter', 'Location', 'best')
xlabel('X-position')
ylabel('Y-position')
zlabel('Z-position')

%Get velocity information
subVelVec = [gradient(subLoc(:, 1), 0.5), gradient(subLoc(:,2), 0.5), gradient(subLoc(:,3), 0.5)];
subSpeed = sqrt((subVelVec(:,1).^2)+(subVelVec(:,2).^2)+(subVelVec(:,3).^2));
%figure, plot(subSpeed);
aveSpeed = mean(subSpeed)
stdSpeed = std(subSpeed)

%Fit Data to Helical functions
t=linspace(0,24,49);
f = fittype('a*sin(d*(x+b))+c', 'independent', 'x');
fx = fit(t', subLoc(:, 1), f, 'StartPoint', [4 -12 -2 0.24]);
fy = fit(t', subLoc(:, 2), f, 'StartPoint', [3 -5 3 0.1817]);
fz = fit(t', subLoc(:, 3), 'poly1');

%Plot Fit Results
figure;
hold on;
plot(fx, '-r', t', subLoc(:, 1), '.k')
plot(fy, '-g', t', subLoc(:, 2), '.k')
plot(fz, '-b', t', subLoc(:, 3), '.k')
ylabel('Magnitude')
legend('Data', 'Fit X', 'Data', 'Fit Y', 'Data', 'Fit Z')
xlabel('Time (hours)')
title('Helical Trajectory Fit')
hold off

%Print Functions
disp('Helix Fit Functions:')
disp('--------------------')
fprintf('x(t) = %5.2f sin[%5.2f * (t + %5.2f)] + %5.2f\n', fx.a, fx.d, fx.b, fx.c);
fprintf('y(t) = %5.2f sin[%5.2f * (t + %5.2f)] + %5.2f\n', fy.a, fy.d, fy.b, fy.c);
fprintf('z(t) = %5.2f * t + %5.2f\n', fz.p1, fz.p2);

%Function for finding 3D integral using trapz method
function int = Int3(x_, F)
    int = trapz(x_, trapz(x_, trapz(x_, F)));
end

%Find expected value of operator M using F as a PDF, F is filtered with a
%simple threshold thres to localize the generated PDF
function val = ExpVal(x_, F,  M, thres)
    F = abs(F)/max(abs(F(:)));
    F = F.*(F>thres);
    PDF = F/Int3(x_, F);
    val = Int3(x_, PDF.*M);
end