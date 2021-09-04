clear
close all
clc

addpath(genpath('../../common'))

n = [6, 6, 6, 4]; % n_pos = 7, n_psi = 4
k = [4, 4, 4, 2]; % k_pos = 4, k_psi = 2;
t_key = [0, 1, 2];
sigma_key = [...
    [0; 0; 0; 0],...
    [0.3; 0.5; 0.2; deg2rad(5)],...
    [1; 1; 0.5; deg2rad(10)]];

trajGeneration = MinSnapTrajGeneration(n, k, t_key, sigma_key);
traj_1 = trajGeneration.generateTraj();
traj_1.plot();

optimizeTime = true;
traj_2 = trajGeneration.generateTraj(optimizeTime);
traj_2.plot();

rmpath(genpath('../../common'))