clear
close all
clc

addpath(genpath('../../common'))

n = [7, 7, 7, 4]; % n_pos = 7, n_psi = 4
k = [4, 4, 4, 2]; % k_pos = 4, k_psi = 2;
t_key = [0, 2.5, 5];
sigma_key = [...
    [0; 0; 0; 0],...
    [0.3; 0.5; 0.2; deg2rad(5)],...
    [1; 1; 0.5; deg2rad(10)]];

trajGeneration = MinSnapTrajGeneration(n, k, t_key, sigma_key);
traj = trajGeneration.generateTraj();
traj.plot();

optimizeTime = true;
optTimeTraj = trajGeneration.generateTraj(optimizeTime);
optTimeTraj.plot();

posTrajFun = DiscreteFunction(@(t) optTimeTraj.posTrajectory(t), 1/100); % 100 [Hz]
headTrajFun = DiscreteFunction(@(t) optTimeTraj.headTrajectory(t), 1/100); % 100 [Hz]

model = GeoPosTracking();
Simulator(model).propagate(0.01, 5, true, posTrajFun, headTrajFun);
model.quadrotor.plot();

rmpath(genpath('../../common'))