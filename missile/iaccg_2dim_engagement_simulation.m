addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Two dimensional IACCG engagement for a nonmaneuvering target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 50;

missile = PlanarMissile3dof(...
    [0; 0; 200; deg2rad(30)]);
missile.fovLimit = deg2rad(45);
missile.accLimit = ...
    [-inf, inf;
    -5*FlatEarthEnv.gravAccel, 5*FlatEarthEnv.gravAccel];
target = PlanarNonManeuvVehicle3dof(...
    [5000; 0; 50; 0]);
gamma_imp = deg2rad(71);

model = IACCGEngagement(missile, target, gamma_imp);
Simulator(model).propagate(dt, finalTime, true);
model.plot();
model.report();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))