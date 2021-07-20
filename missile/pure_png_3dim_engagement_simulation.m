addpath(genpath('../core'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Three dimensional pure PNG engagement for a stationary target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 20;
system = PurePNG3dimEngagement();

tic
Simulator(system).propagate(dt, finalTime, true);
elapsedTime = toc;

system.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('./'))