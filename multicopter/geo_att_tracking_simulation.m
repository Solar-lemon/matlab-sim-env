addpath(genpath('../core'))
addpath(genpath('../common'))
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

trajFun = DiscreteFunction(@trajectory, 1/100); % 100 [Hz]

tic
Simulator(simulation).propagate(dt, finalTime, true, trajFun);
elapsedTime = toc;

simulation.quadrotor.plot();
simulation.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('../matlab-deriv-operation'))
rmpath(genpath('./'))

function var_R_d = trajectory(time)
var_t = IndepVariable(time, 1);
var_phi = 0.1*sin(2*pi*var_t/5);
var_theta = 0.1*sin(2*pi*var_t/10);
var_psi = 0.1*var_t;

var_R_d = Orientations.eulerAnglesToRotation(var_phi, var_theta, var_psi).';
end
                    