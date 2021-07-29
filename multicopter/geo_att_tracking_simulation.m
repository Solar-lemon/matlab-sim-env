addpath(genpath('../core'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

dt = 0.01;
finalTime = 5;
simulation = GeoAttTracking();

tic
Simulator(simulation).propagate(dt, finalTime, true);
elapsedTime = toc;

simulation.quadrotor.plot();
simulation.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))