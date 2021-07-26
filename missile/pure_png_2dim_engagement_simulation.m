addpath(genpath('../core'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Two dimensional pure PNG engagement for a stationary target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 30;
system = PurePNG2dimEngagement();

tic
Simulator(system).propagate(dt, finalTime, true);
elapsedTime = toc;
missDistance = system.missDistance();

system.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)
fprintf("Miss distance: %.4f [m] \n", missDistance)

rmpath(genpath('../core'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))