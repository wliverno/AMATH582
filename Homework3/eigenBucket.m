function EB = eigenBucket(movie, numImages, skip)
    % Get Data Set by cropping images
    maxSubX = 0;
    maxSubY = 0;
    [lx,ly,~,n] = size(movie);
    bucketList = zeros(lx, ly, numImages);
    for i=1:numImages
        imshow(im2gray(movie(:,:,:,i*skip))), drawnow;
        subim = imcrop;
        clf
        [subX, subY] = size(subim);
        bucketList(1:subX,1:subY, i) = double(subim);
        if subX>maxSubX
            maxSubX = subX;
        end
        if subY>maxSubY
            maxSubY = subY;
        end
    end
    bucketListCropped = bucketList(1:maxSubX, 1:maxSubY, :);
       
    %Singular Value Decomposition
    A = zeros(numImages, maxSubX*maxSubY);
    for i=1:numImages
        A(i, :) = reshape(bucketListCropped(:, :, i), 1, maxSubX*maxSubY);
    end
    [V,D] = eigs(A'*A, 20, 'lm');
    d = diag(D);
    EBVec = abs(V*d)/max(abs(V*d));
    
    %Write eigenbucket as image
    EB = zeros(lx, ly);
    EB(1:maxSubX, 1:maxSubY) = reshape(EBVec*255,maxSubX, maxSubY);
    EB = uint8(EB);
    imshow(EB);
end