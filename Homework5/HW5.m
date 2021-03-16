clear all, close all, clc;

[fgmc, bgmc] = dmdBgSub('monte_carlo_low.mp4', 100, 0.1);
n = size(fgmc, 3);
fgmcvid = VideoWriter('monte_carlo_FG.mp4');
open(fgmcvid);
for i=1:n
    writeVideo(fgmcvid, fgmc(:, :, i));
end
close(fgmcvid);

[fgski, bgski] = dmdBgSub('ski_drop_low.mp4', 100, 0.1);
n = size(fgski, 3);
fgskivid = VideoWriter('ski_drop_FG.mp4');
open(fgskivid);
for i=1:n
    writeVideo(fgskivid, fgski(:, :, i));
end
close(fgskivid);
