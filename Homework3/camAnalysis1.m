
function [lambda, Y, U] = camAnalysis1(vidFramesList, xCropList, yCropList)
    
    n=200;
    
    %Loop through up to frame n and store values to matrix 
    X = zeros(6, n);
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
            %Get current frame
            frame = double(im2gray(vidFrames(:,:,:,i)));
            frame = frame*255/max(frame(:));
            
            %Image stabilization
            [refX, refY] = getLocRef(frame,img, 0);
            refX = refX-320;
            refY = refY-240;
            try
                frame=imtranslate(frame, [-refX -refY]);
            end
            %Get coordinates of paint can
            [x(i), y(i)] = getLocCan(frame, xCrop, yCrop, 240);
            
            %In case of tracking failure, use previous data point
            if isnan(x(i))&(i>1)
                x(i) = x(i-1);
            end
            if isnan(y(i))&(i>1)
                y(i) = y(i-1);
            end
            %subplot(2,3,j), imshow(uint8(frame)), drawnow; %View video
        end
        t=1:n;
        subplot(2,3,j), plot(t,x,t,y);
        legend('x','y');
        title(['Cam ', num2str(j)]);
        X(j*2-1, :) = x(1:n)-mean(x(1:n));
        X(j*2, :) = y(1:n)-mean(y(1:n));
    end

    %PCA Analysis
    [U, S, V] = svd(X/sqrt(5));
    lambda = diag(S).^2;
    Y =U'*X;
    subplot(2,3,4), plot(t,Y(1,:)), title(['Component 1, \Lambda=', num2str(lambda(1), '%.2e')]);
    subplot(2,3,5), plot(t,Y(2,:)), title(['Component 2, \Lambda=', num2str(lambda(2), '%.2e')]);
    subplot(2,3,6), plot(t,Y(3,:)), title(['Component 3, \Lambda=', num2str(lambda(3), '%.2e')]);
    
end

%Track paint can within bounds using specified threshold
function [xloc, yloc] = getLocCan(img, xcrop, ycrop, thres)
    [XC, YC] = meshgrid(xcrop, ycrop);
    croppedImg = double(img(ycrop, xcrop));
    croppedImg(croppedImg<=thres) = 0;
    xloc=sum(croppedImg.*XC, 'all')/sum(croppedImg, 'all');
    yloc=sum(croppedImg.*YC, 'all')/sum(croppedImg, 'all');
end

%Track kernel (img2) within image (img), return expected location with
%thres cutoff
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