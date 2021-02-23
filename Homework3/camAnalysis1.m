clear all, close all

%Load videos, reference images
load cam1_3.mat
load cam2_3.mat
load cam3_3.mat
vidFramesList={vidFrames1_3, vidFrames2_3, vidFrames3_3};
[~,~,~,n] = size(vidFrames3_3);
n = 200; 

%Set crop locations to track can
xCropList ={250:400, 200:375, 150:600};
yCropList ={1:480, 200:480, 200:350}; %3_3, 3_2, 3_3 - 225:350, 3_4 - 125:350

%Loop through up to numFrames and store values to matrix 
A = zeros(6, n);
figure;
for j = 1:3
    vidFrames = cell2mat(vidFramesList(j));
    imgf = fft2(double(im2gray(vidFrames(:,:,:,1))));
    for i=2:n
        imgf=imgf+fft2(double(im2gray(vidFrames(:,:,:,i))));
    end
    imgf=imgf/n;
    img = ifft2(imgf);
    [ly,lx] = size(img);
    xCrop=cell2mat(xCropList(j)); 
    yCrop=cell2mat(yCropList(j)); 
    x=zeros(1,n);
    y=zeros(1,n);
    for i=1:n
        frame = double(im2gray(vidFrames(:,:,:,i)));
        frame = frame*255/max(frame(:));
        [refX, refY] = getLocRef(frame,img, 0);
        refX = refX-320;
        refY = refY-240;
        try
            frame=imtranslate(frame, [-refX -refY]);
        end
        [x(i), y(i)] = getLocCan(frame, xCrop, yCrop, 240);
        %subplot(3,1,j), imshow(uint8(frame)), drawnow;
    end
    t=1:n;
    subplot(3,1,j), plot(t,x,t,y);
    legend('x','y');
    title(['Cam ', num2str(j)]);
    A(j*2-1, :) = x(1:n)-mean(x(1:n));
    A(j*2, :) = y(1:n)-mean(y(1:n));
end

function [xloc, yloc] = getLocCan(img, xcrop, ycrop, thres)
    [XC, YC] = meshgrid(xcrop, ycrop);
    croppedImg = double(img(ycrop, xcrop));
    croppedImg(croppedImg<=thres) = 0;
    xloc=sum(croppedImg.*XC, 'all')/sum(croppedImg, 'all');
    yloc=sum(croppedImg.*YC, 'all')/sum(croppedImg, 'all');
end

function [xloc, yloc] = getLocRef(img, img2, thres)
    w = conj(fft2(img2));
    f = fft2(double(img));
    cnv = f.*w;
    cnv = cnv./abs(cnv);
    cnv = abs(ifft2(cnv));
    cnv(:,1) = 0;
    cnv(:,end) = 0;
    cnv(1,:) = 0;
    cnv(end,:) = 0;
    locGraph = cnv/max(cnv(:));
    locGraph = locGraph.*(locGraph>thres);
    [ly,lx] = size(img);
    [X, Y] = meshgrid(1:lx, 1:ly);
    xloc = round(sum(locGraph.*X, 'all')/sum(locGraph, 'all'));
    yloc = round(sum(locGraph.*Y, 'all')/sum(locGraph, 'all'));
    if isnan(xloc)
        xloc = 0;
    end
    if isnan(yloc)
        yloc=0;
    end
end