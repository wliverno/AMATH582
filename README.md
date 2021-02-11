# AMATH582
Projects and homework for the UW AMATH 582 Computational Methods For Data Analysis class 

## Homework 1
To run, first extract `subdata.mat` from [this zip file.](https://drive.google.com/file/d/1M5ii0R3MTedi6T8AZLI06rIqz1BgpAVg/view?usp=sharing)
Run `HW1.m` to process data, produce visualizations, and print results. See `HW1.pdf` for a detailed description of the results.

## Homework 2
Several scripts were written to generate a spectrogram and generate a music score from an audio file. The first of these is "getSpectrogram.m" which ouputs a `spectrogram` matrix with time vector `tg` and frequency vector `freq` given the inputs:

```
[spectrogram, tg, freq] = getSpectrogram('GNR.m4a', 0.05, 10000)
```

which would open the GNR.m4a song and use a window width of 0.05 seconds and a maximum frequency of 10000 Hz to generate and display the spectrogram. The "reverseSpectrogram.m" script converts the spectrogram back to the audio data and frequency information:

```
[audio, frequency] = reverseSpectrogram(spectrogram, tg, freq)
```

Finally, the "getNotes.m" script creates a musical score from an input file and frequency bounds:

```
out = getNotes('GNR.m4a, 800, 200)
```

where `out` contains two string columns with timing and note location (i.e. C4, A#2). The "floydAnalysis.m" file contains a demo of these tools and is described in more detail in HW2.pdf.