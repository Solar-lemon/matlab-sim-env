clear
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))
set(0,'DefaultFigureWindowStyle','docked')

fprintf('== Test for SecondOrderDynSystem == \n')
zeta = 0.5;
omega = 1;
system = SecondOrderDynSystem([0; 0], zeta, omega);
dt = 0.01;
finalTime = 10;
saveHistory = true;

tic
u_step = 1;
Simulator(system).propagate(dt, finalTime, saveHistory, u_step);

u_step = 2;
Simulator(system).propagate(dt, finalTime, saveHistory, u_step);

u_step = 3;
Simulator(system).propagate(dt, finalTime, saveHistory, u_step);

elapsedTime = toc;
fprintf("Elapsed time: %.2f [s] \n\n", elapsedTime);
system.plot();
system.plotError();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
set(0,'DefaultFigureWindowStyle','normal')