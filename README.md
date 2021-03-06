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
## Homework 3
Several scripts were written to analyze camera footage of a paint can on a spring. Three cameras were used to capture videos of 4 experimental setups that must be [downloaded as matrix files](https://drive.google.com/drive/folders/1SQ77P5t5RUWCSucmk4jPFbufFMX8VrJG?usp=sharing). Principle component analysis was used to isolate the orthagonal directions of motion. To plot the analysis of the experiments, run `HW3.m`. A helper function was also used to isolate features from multiple frames of the photo called `eigenBucket.m` that has the following inputs and outputs

```
[EB] = eigenBucket(movie, numImages, skip)
```

where `movie` is a 4D matrix containing the RGB video, `numImages` is the total number of images to process, and `skip` is the sampling rate of frames to average the image. The output, `EB` is a grayscale image with the same dimensions as each frame in `movie` containing the 20 most common eigen-features of the frame combined into a single image.

## Homework 4

This homeworked use principle components analysis and simple supervised machine-learning algorithms to read digits from images using the MNIST handwritten digits database. To get started, download and extract the four gzip archives from [http://yann.lecun.com/exdb/mnist/](http://yann.lecun.com/exdb/mnist/) to your local directory. Then run `mnistSVD.m` to generate the basis matrices, which will be stored in the file `pcaMats.mat`. Finally, run the `mnistClassifiers.m` file to test the various classifiers and visualize data clusters.

## Homework 5
Dynamic mode decomposition (DMD) was used to separate the foreground and background of images. Using a low-rank basis and isolating low frequency DMD modes, background subtraction was used to isolate moving features. The general function from `dmdBgSub.m` was used to process the images with the following arguments

```
[fgvid, bgvid] = edmdBgSub(filename, rank, cutoff)
```
where the `rank` variable determined the number of SVD modes to use for background reconstruction and the `cutoff` variable was used as an upper limit to the frequency for the background DMD modes.

A demo of this was implemented in `HW5.m` which processes two video files that can be [downloaded here.](https://drive.google.com/drive/folders/1SQ77P5t5RUWCSucmk4jPFbufFMX8VrJG?usp=sharing). The grayscale foreground and background videos are written to AVI movie files.

## Final Project
Quantum transport through a DNA structure was monitored as a function of the contact self-energies. Looking at principle components of the transmission spectrum and applying regularization methods it was possible to determine the correlation between the self-energies of the contacts and the transmission energy levels present in the structure. Run `TransmissionAnalysis.m` to visualize the principle components analysis and regression methods. Run `DOSPlot.m` to compare the weighting of the contact self-energies to the locations of peaks in the 2D density of states plot.
