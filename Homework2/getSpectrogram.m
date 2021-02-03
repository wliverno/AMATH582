function spectrogram = getSpectrogram(inputFile, width, maxFreq)
    %Default iNPUTS
    %inputFile ='GNR.m4a'
    %width=0.1; % window width (sec)
    %maxFreq=12000; %Hertz
    
    [y, Fs] = audioread(inputFile);
    tEnd = length(y)/Fs;
    t =(1:length(y))/Fs;

    %Compress file to cutoff higher frequency terms
    maxFreq = maxFreq - rem(maxFreq, 1/width);
    tc = linspace(0,tEnd,maxFreq*tEnd);
    yc = interp1(t, y, tc);
    yc(1) = 0;

    %Plot time domain signal
    subplot(2,1,1), plot(tc,yc);
    xlabel('Time [sec]');
    ylabel('Amplitude');
    title(inputFile);

    %Gabor Transform Lists
    tg = 0:(width/2):tEnd; 
    n = width*maxFreq;
    tw = linspace(0,width,n);
    freqs = (1/width)*[0:(n/2 - 1) -n/2:-1]; freq=fftshift(freqs);
    spectrogram = zeros(n,length(tg));
    filt = exp(-10*((tw/width)-0.5).^2);

    %Apply Transform across windows
    for i=2:(length(tg)-1)
        firstInd = round(tg(i-1)*maxFreq+1);
        lastInd = round(tg(i+1)*maxFreq);
        ind = firstInd:lastInd;
        if length(ind)<n
            y_= padarray(yc(ind), n-length(ind));
        else
            y_=yc(ind);
        end
        yf = filt.*y_;
        spectrogram(:,i) = ifftshift(abs(fft(yf)));
    end
    %Plot Results and play song
    subplot(2,1,2), contourf(tg, freq, spectrogram, 'LineStyle', 'none'), colormap(hot);
    xlabel('Time [sec]');
    ylabel('Freq [Hz]');
    title('Spectrogram');
    axis([0 tEnd 0 maxFreq/8])
    p8 = audioplayer(yc,maxFreq);
    playblocking(p8);
end

