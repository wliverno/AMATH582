clear all, close all;

load notedata.mat

[spec, tg, freq] = getSpectrogram('Floyd.m4a',0.05, 20000);
n = length(freq);
width = tg(2);
Fs = n/(2*width);

%An attempt at removing melody + overtones (not used)
%spec = filterNotes(spec, freq, tg, 450, 250);
%spec = filterNotes(spec, freq, tg, 550, 300);
%spec = filterNotes(spec, freq, tg, 700, 400);
%spec = filterNotes(spec, freq, tg, 900, 500);
%spec = filterNotes(spec, freq, tg, 500, 400);

% [maxFreq, yback] = reverseSpectrogram(spec,tg,freq);
% tback =(1:length(yback))/maxFreq;
% p8 = audioplayer(yback(1:length(yback)/8),maxFreq);
% playblocking(p8);

%Simple Low-Pass Filter
f0 = 150; %Hz
filt = 1./(1+(1i*freq/f0))'; %Positive Frequencies
filt = filt./(1-(1i*freq/f0))';  %Negative Frequencies
filt = filt.^2; %Poof - now it's a second order filter!
specbass = zeros(size(spec));
for i=1:length(tg)
    specbass(:, i) = spec(:, i).*filt;
end

%Simple High-Pass Filter
f0 = 250; %Hz
filt = (freq/f0)'./(1+(1i*freq/f0))'; %Positive Frequencies
filt = filt.*(freq/f0)'./(1-(1i*freq/f0))';  %Negative Frequencies
filt = 2*filt.^2; %Poof - now it's a second order filter!
specmelody = zeros(size(spec));
for i=1:length(tg)
    specmelody(:, i) = spec(:, i).*filt;
end

%Plot spectrograms
figure;    
normSpec = abs(spec);
normSpecBass = abs(specbass);
normSpecMelody = abs(specmelody);
subplot(1,3,1), contourf(tg, freq, normSpec, 'LineStyle', 'none'), colormap(hot);
xlabel('Time [sec]');
ylabel('Freq [Hz]');
title('Unfiltered Spectrogram');
axis([0 10 0 1000])
subplot(1,3,2), contourf(tg, freq, normSpecBass, 'LineStyle', 'none'), colormap(hot);
xlabel('Time [sec]');
ylabel('Freq [Hz]');
title('Bass Spectrogram (Low Pass Filter)');
axis([0 10 0 1000])
subplot(1,3,3), contourf(tg, freq, normSpecMelody, 'LineStyle', 'none'), colormap(hot);
xlabel('Time [sec]');
ylabel('Freq [Hz]');
title('Melody Spectrogram (High Pass Filter)');
axis([0 10 0 1000])

% Debugging - inspect resulting audio signal and listen to playback
[maxFreq, yback] = reverseSpectrogram(specmelody,tg,freq);
tback =(1:length(yback))/maxFreq;
%figure;
%subplot(2,1,1), plot(tback, yback);
%p8 = audioplayer(yback(1:length(yback)/8),maxFreq);
%playblocking(p8);

[bassNotes, bassNoteTimes] = getNotesSpec(normSpecBass, freq, tg, 150, 20, 10)
[melodyNotes, melodyNoteTimes] = getNotesSpec(normSpecMelody, freq, tg, 600, 200, 5)

%Method for getting notes from filtered spectrum
function [notes, times] = getNotesSpec(normSpec, freq, tg, upper, lower, smoothfactor)
    load notedata.mat
    inds = zeros(1, length(tg));
    for i=1:length(tg)
        ft = normSpec(freq>lower & freq < upper,i)'.*(normSpec(freq>lower & freq < upper,i)'>1);
        f = freq(freq>lower & freq < upper);
        expFreq = sum(ft.*f)/sum(ft);
        [minValue,ind] = min(abs(noteFreq-expFreq));
        if expFreq > 0 
            inds(i) = ind;
        elseif i>1
            inds(i) = inds(i-1);
        else
            inds(i) = ind;
        end
    end
    %Smooth results using the mode
    indsFilt = zeros(1, length(tg));
    notes = ["Begin"];
    times = [0];
    for i=1:length(tg)
        if i<=smoothfactor/2
            indsFilt(i) = mode(inds(1:smoothfactor));
        elseif i>=length(tg) - smoothfactor/2
            indsFilt(i) = mode(inds(length(tg)-smoothfactor:end));
        else
            indsFilt(i) = mode(inds(i-floor(smoothfactor/2):i+floor(smoothfactor/2)));
        end
        currentNote = noteStrings(indsFilt(i));
        if (notes(end)~=currentNote) 
            times = [times, tg(i)];
            notes = [notes, noteStrings(indsFilt(i))];
        end
    end
    figure;
    plot(tg, noteFreq(indsFilt));
end

%Unused method for removing melody and overtones
function spec = filterNotes(spec, freq, tg, upperThreshFreq, lowerThreshFreq)
    rng = upperThreshFreq-lowerThreshFreq;
    [foo,indUp] = min(abs(freq-upperThreshFreq));
    [foo,indLo] = min(abs(freq-lowerThreshFreq));
    for i=1:length(tg)
        ft = abs(spec(indLo:indUp,i))'.*(abs(spec(indLo:indUp,i))'>0.7);
        %spec(indLo:indUp,i) = spec(indLo:indUp,i).*~ft';
        f = freq(indLo:indUp);
        expFreq = sum(ft.*f)/sum(ft);
        if ~isnan(expFreq)
            filter = ones(1, length(freq));
            for j=1:3
                filter = filter - exp(-1*(freq - (j*expFreq)).^2/(1000));
                filter = filter - exp(-1*(freq + (j*expFreq)).^2/(1000));
            end
            %filter = filter.^4;
            spec(:,i) = real(spec(:,i)).*filter' + (1i*imag(spec(:,i)));
        else
            warning('Frequency Omitted');
        end
    end
end