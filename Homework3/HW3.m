close all

%Experiment 1 - One direction of motion
load cam1_1.mat
load cam2_1.mat
load cam3_1.mat
vidFramesList={vidFrames1_1, vidFrames2_1(:,:,:,10:end), vidFrames3_1};
xCropList ={250:400, 200:380, 150:600};
yCropList ={1:480, 180:450, 225:350};
[lambda1, Y1, U1] = camAnalysis1(vidFramesList,xCropList,yCropList);

%Experiment 2 - One direction of motion with noise
load cam1_2.mat
load cam2_2.mat
load cam3_2.mat
xCropList ={250:400, 200:400, 175:600};
yCropList ={1:480, 140:420, 200:350};
vidFramesList={vidFrames1_2(:,:,:,17:end), vidFrames2_2, vidFrames3_2(:,:,:,17:end)};
figure;
[lambda2, Y2,  U2] = camAnalysis1(vidFramesList,xCropList,yCropList);

%Experiment 3 - Two directions of motion
load cam1_3.mat
load cam2_3.mat
load cam3_3.mat
vidFramesList={vidFrames1_3(:,:,:,16:end), vidFrames2_3, vidFrames3_3(:,:,:,6:end)};
xCropList ={250:400, 225:400, 170:600};
yCropList ={1:480, 150:450, 200:400};
[lambda3, Y3, U3] = camAnalysis1(vidFramesList,xCropList,yCropList);

%Experiment 4 - Three directions of motion
load cam1_4.mat
load cam2_4.mat
load cam3_4.mat
vidFramesList={vidFrames1_4, vidFrames2_4(:,:,:,7:end), vidFrames3_4};
xCropList ={250:400, 225:400, 200:600};
yCropList ={1:480, 150:450, 100:300};
[lambda4, Y4, U4] = camAnalysis1(vidFramesList,xCropList,yCropList);