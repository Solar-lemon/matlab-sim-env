addpath(genpath('../core'))
addpath(genpath('../lie-algebra'))
addpath(genpath('../matlab-deriv-operation'))
addpath(genpath('./'))

clear
clc
close all

testMode = GeoAttTracking.TRACK_MODE;

dt = 0.01;
finalTime = 5;
simulation = GeoAttTracking(testMode);

tic
Simulator(simulation).propagate(dt, finalTime, true);
elapsedTime = toc;

simulation.quadrotor.plot();
simulation.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('../matlab-deriv-operation'))
rmpath(genpath('./'))