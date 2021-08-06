addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

dt = 0.01;
finalTime = 5;
system = AttQuatStabilization();

Simulator(system).propagate(dt, finalTime, true);
system.quadrotor.plot();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))