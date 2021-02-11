function [Fs, data]= reverseSpectrogram(spectrogram, tg, freq)
    n = length(freq);
    width = tg(2);
    Fs = n/(2*width);
    tw = linspace(0,width,n);
    filt = exp(-10*((tw/width)-0.5).^2);
    data=zeros(floor(tg(end)*Fs),1);
    for i=2:(length(tg)-1)
        firstInd = round(tg(i-1)*Fs+1);
        lastInd = round(tg(i+1)*Fs);
        ind = firstInd:lastInd;
        data(ind) = ifft(fftshift(spectrogram(:,i)))./filt';
    end
end