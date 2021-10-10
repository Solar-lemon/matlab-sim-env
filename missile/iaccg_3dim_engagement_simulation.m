addpath(genpath('../core'))
addpath(genpath('../common'))
addpath(genpath('../lie-algebra'))
addpath(genpath('./'))

clear
clc
close all

fprintf("== Three dimensional IACCG engagement for a nonmaneuvering target == \n")
fprintf("Simulating... \n")

dt = 0.01;
finalTime = 50;

missile = Missile3dof(...
    [0; 0; 0; 200; deg2rad(30); deg2rad(30)]);
missile.fovLimit = deg2rad(45);
target = NonManeuvVehicle3dof(...
    [3000; 0; 0; 50; 0; 0]);
impactAngle = deg2rad([15; 15]);
sigma_d = deg2rad([40; 10]);
% missile = Missile3dof(...
%     [0; 0; 0; 200; deg2rad(30); deg2rad(0)]);
% missile.fovLimit = deg2rad(45);
% target = NonManeuvVehicle3dof(...
%     [5000; 0; 0; 50; 0; 0]);
% impactAngle = deg2rad([0; 71]);
% sigma_d = deg2rad([0; 40]);

model = IACCG3dimEngagement(missile, target, impactAngle, sigma_d);
Simulator(model).propagate(dt, finalTime, true);
model.plot();
model.report();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
rmpath(genpath('../lie-algebra'))
rmpath(genpath('./'))