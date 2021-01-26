clear all; close all; clc

load subdata.mat

L=10
n=64
x2 = linspace(-L, L, n+1); x=x2(1:n);
y = x;
z = x;

k = (2*pi/(2*L))*[0:(n/2 - 1) -n/2:-1]; ks = fftshift(k);

[X,Y,Z] = meshgrid(x,y,z);
[Kx, Ky, Kz] = meshgrid(ks, ks, ks);
Uk = zeros(n,n,n);

for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    M = max(abs(Un),[],'all');
    Uk = Uk + fftn(Un);
    Uks = fftshift(Uk);
%     clf
%     isosurface(X,Y,Z,abs(Un)/M,0.5);
%     axis([-20 20 -20 20 -20 20]), grid on, drawnow
%     isosurface(Kx,Ky,Kz,abs(Uks)/max(abs(Uks(:))),0.5);
%     axis([-10 10 -10 10 -10 10]), grid on, drawnow
%     pause(0.2)
end
aveUks = abs(Uks)/max(abs(Uks(:)));
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
subLoc = zeros(49, 3);
for j=1:49
    Un(:,:,:)=reshape(subdata(:,j),n,n,n);
    Uf = ifftn(filter.*fftn(Un));
    Ufn = abs(Uf)/max(abs(Uf(:)));
    xLoc = ExpVal(x, Ufn, X, cutoff);
    yLoc = ExpVal(y, Ufn, Y, cutoff);
    zLoc = ExpVal(z, Ufn, Z, cutoff);
    subLoc(j, :) = [xLoc yLoc zLoc];
end

figure;
plot3(subLoc(:, 1), subLoc(:, 2), subLoc(:, 2))

% figure;
% isosurface(X,Y,Z,Ufn,0.9);
% axis([-10 10 -10 10 -10 10]), grid on, drawnow
% figure;
% isosurface(X,Y,Z,abs(Un)/max(abs(Un(:))),0.9);
% axis([-10 10 -10 10 -10 10]), grid on, drawnow
%     axis([-20 20 -20 20 -20 20]), grid on, drawnow

%Triple integral of a cubic matrix F along x_ in each dimension
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