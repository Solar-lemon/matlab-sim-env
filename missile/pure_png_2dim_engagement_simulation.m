addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Two dimensional pure PNG engagement for a stationary target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 30;
missile = PlanarMissile3dof(...
    [-5E3; 3E3; 300; deg2rad(-30)]);
% missile.fovLimit = deg2rad(1.5);
target = PlanarNonManeuvVehicle3dof(...
    [0; 0; 20; 0]);
model = PurePNG2dimEngagement(missile, target);

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