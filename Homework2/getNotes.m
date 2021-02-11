function out = getNotes(file, upperThres, lowerThres)
    %Load library
    load notedata.mat
    %Load spectrogram
    [spec, tg, freq] = getSpectrogram(file,0.05, 10000);
    %Loop through and extract notes
    notes = ["Begin"];
    times = [0];
    freqs = zeros(1, length(tg)); 
    inds = zeros(1, length(tg)); 
    for i=1:length(tg)
        ft = abs(spec(freq>lowerThres & freq<upperThres,i))';
        ft = ft.*(ft>1);
        f = freq(freq>lowerThres & freq<upperThres);
        expFreq = sum(ft.*f)/sum(ft);
        [minValue,ind] = min(abs(noteFreq-expFreq));
        freqs(i) = expFreq;
        inds(i)=ind;
        if (isnan(expFreq) | expFreq == 0) & i>1
            freqs(i) = freqs(i-1);
            inds(i)=inds(i-1);
        else
            freqs(i) = expFreq;
            inds(i)=ind;
        end

        if (notes(end)~=noteStrings(ind)) & (expFreq<upperThres)
            times = [times, tg(i)];
            notes = [notes, noteStrings(ind)];
        end
    end
    %Debugging: Plot note frequencies
    figure;
    plot(tg,noteFreq(inds))
    axis([0 tg(end) lowerThres upperThres])
    out = [string(times)', notes']
end