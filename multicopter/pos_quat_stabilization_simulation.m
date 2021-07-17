addpath(genpath('../core'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

dt = 0.01;
finalTime = 10;
system = PosQuatStabilization();

Simulator(system).propagate(dt, finalTime, true);
system.quadrotor.plot();

rmpath(genpath('../core'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))