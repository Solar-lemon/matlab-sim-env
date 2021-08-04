addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('../matlab-deriv-operation'))
addpath(genpath('./'))

clear
clc
close all

dt = 0.01;
finalTime = 10;
simulation = GeoPosTracking();

posTrajFun = DiscreteFunction(@posTrajectory, 1/100); % 100 [Hz]
headTrajFun = DiscreteFunction(@headTrajectory, 1/100); % 100 [Hz]

tic
Simulator(simulation).propagate(dt, finalTime, true, posTrajFun, headTrajFun);
elapsedTime = toc;

simulation.quadrotor.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('../matlab-deriv-operation'))
rmpath(genpath('./'))

function var_x_d = posTrajectory(time)
var_t = IndepVariable(time, 3);
var_x_d = [0.4*var_t; 0.4*sin(pi*var_t); 0.6*cos(pi*var_t)];
end

function var_psi_d = headTrajectory(time)
var_t = IndepVariable(time, 1);
var_psi_d = pi*var_t;
end