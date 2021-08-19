addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Three dimensional pure PNG engagement for a stationary target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 50;
missile = Missile3dof(...
    [-2500; -100; -2500; 200; deg2rad(-45); deg2rad(5)]);
% missile.fovLimit = deg2rad(3.5);
target = NonManeuvVehicle3dof(...
    [0; 0; 0; 20; 0; 0]);
model = PurePNG3dimEngagement(missile, target);

tic
Simulator(model).propagate(dt, finalTime, true);
elapsedTime = toc;
missDistance = model.missDistance();

model.plot();
fprintf("Elapsed time: %.2f [s] \n", elapsedTime)
fprintf("Miss distance: %.4f [m] \n", missDistance)

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))