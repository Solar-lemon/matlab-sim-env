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

trajFun = DiscreteFunction(@trajectory, 1/100); % 100 [Hz]

tic
Simulator(simulation).propagate(dt, finalTime, true, trajFun);
elapsedTime = toc;

simulation.quadrotor.plot();
simulation.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)

rmpath(genpath('../core'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('../matlab-deriv-operation'))
rmpath(genpath('./'))

function R_d = trajectory(time)
t = IndepVariable(time, 1);
phi = 0.1*sin(2*pi*t/5);
theta = 0.1*sin(2*pi*t/10);
psi = 0.1*t;

R_d = Orientations.eulerAnglesToRotation(phi, theta, psi).';
end
                    