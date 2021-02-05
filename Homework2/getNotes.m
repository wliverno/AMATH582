load notedata.mat

[spec, tg, freq] = getSpectrogram('GNR.m4a',0.05, 10000);

notes = ["Begin"];
times = [0];
for i=1:length(tg)
    ft = spec(round(length(freq))/2:end,i)'>1;
    f = freq(round(length(freq))/2:end);
    expFreq = sum(ft.*f)/sum(ft);
    [minValue,ind] = min(abs(noteFreq-expFreq));
    if (notes(end)~=noteStrings(ind)) & (expFreq<800)
        times = [times, tg(i)];
        notes = [notes, noteStrings(ind)];
    end
end
notes