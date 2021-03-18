clear all, close all, clc;

[fgmc, bgmc] = dmdBgSub('monte_carlo_low.mp4', 100, 0.2);
n = size(fgmc, 3);
fgmcvid = VideoWriter('monte_carlo_FG');
bgmcvid = VideoWriter('monte_carlo_BG');
open(fgmcvid);
open(bgmcvid);
for i=1:n
    writeVideo(fgmcvid, fgmc(:, :, i));
    writeVideo(bgmcvid, bgmc(:, :, i));
end
close(fgmcvid);
close(bgmcvid);

[fgski, bgski] = dmdBgSub('ski_drop_low.mp4', 50, 0.2);
n = size(fgski, 3);
fgskivid = VideoWriter('ski_drop_FG');
bgskivid = VideoWriter('ski_drop_BG');
open(fgskivid);
open(bgskivid);
for i=1:n
    writeVideo(fgskivid, fgski(:, :, i));
    writeVideo(bgskivid, bgski(:, :, i));
end
close(fgskivid);
close(bgskivid);
