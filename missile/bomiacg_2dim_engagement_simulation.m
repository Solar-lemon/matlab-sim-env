addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Two dimensional BOMIACG engagement for a stationary target == \n")

dt = 0.01;
finalTime = 100;

missile = PlanarMissile3dof(...
    [0; 0; 250; deg2rad(15)]);
missile.fovLimit = deg2rad(30);
missile.accLimit = ...
    [-inf, inf;
    -10*FlatEarthEnv.gravAccel, FlatEarthEnv.gravAccel];
target = PlanarNonManeuvVehicle3dof(...
    [10E3; 0; 0; 0]);
gamma_d = deg2rad(-60);

model = BOMIACGEngagement(missile, target, gamma_d);
Simulator(model).propagate(dt, finalTime, true);
model.plot();
model.report();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('./'))