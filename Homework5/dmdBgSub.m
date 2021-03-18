function [fgVid, bgVid] = dmdBgSum(filename, rank, cutoff)
    frames = read(VideoReader(filename));
    [lx,ly,~,n] = size(frames)

    X = zeros(lx*ly, n);
    for i=1:n
        frame = double(im2gray(frames(:,:,:,i)));
        X(:, i) = reshape(frame, lx*ly, 1);
    end

    X1 = X(:, 1:end-1);
    X2 = X(:, 2:end);


    % SVD of original image matrix, with rank cutoff applied 
    %rank=100;
    [U, S, V] = svd(X1, 'econ');
    U = U(:, 1:rank);
    V = V(:, 1:rank);
    S = S(1:rank, 1:rank);
    
    % DMD calculations applying Koopman operator to generate dynamic modes 
    Ar = U'*X2*V/S;
    [W, D] = eig(Ar);
    Lambda = diag(D);
    omega = log(Lambda);
    phi = U*W;
    x0 = phi\X(:,1);
    u_modes = zeros(rank,n); 
    for i = 1:n
      u_modes(:,i) =(x0.*exp(omega*i)); 
    end
    
    % Plot calculated omega values in the complex plane
    figure; plot(real(omega), imag(omega), 'ko');
    title('DMD mode \omega-values'), xlabel('Re(\omega)'), ylabel('Im(\omega)');

    % Reconstruct background using omega cutoff
    modes = abs(omega)<cutoff;
    u_back = phi(:, modes)*u_modes(modes, :);
    
    % Specify which frames to preview
    figure;
    preview = [50, 100, 200];
    % Write background and foreground images frame by frame
    j = 1;
    fgVid = uint8(zeros(lx, ly, n));
    bgVid = uint8(zeros(lx, ly, n));
    for i=1:n
        backgroundvec = abs(u_back(:,i));
        framevec = abs(X(:,i));
        foregroundvec = framevec-backgroundvec;
        % negInds = foregroundvec<0;
        % backgroundvec(negInds) = backgroundvec(negInds) - foregroundvec(negInds);
        foregroundvec = foregroundvec - min(foregroundvec);
        bg = uint8(reshape(backgroundvec, lx, ly)*255/max(backgroundvec));
        fg = uint8(reshape(foregroundvec, lx, ly)*255/max(foregroundvec));
        % Plot the original, FG, and BG of specified frames
        if ismember(i, preview) 
            im = uint8(reshape(framevec, lx, ly)*255/max(framevec));
            subplot(length(preview),3,(j-1)*3+1), imshow(im), title(['Original Frame #',num2str(preview(j))]), drawnow;
            subplot(length(preview),3,(j-1)*3+2), imshow(bg), title('Background'), drawnow;
            subplot(length(preview),3,(j-1)*3+3), imshow(fg), title('Foreground'), drawnow;
            j=j+1;
        end
        bgVid(:, :, i)=bg;
        fgVid(:, :, i)=fg;
    end
end
