clear all
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

m = 1;
c = 6;
k = 9.8696;
A = [0, 1; -k/m, -c/m];
B = [0; 1/m];
C = [1, 0];

k_p = 50;
k_i = 45;
k_d = 8;

dynSys = DynSystem({[0; 0]}, {'x'}, {'u'}, ...
    @(x, u) {A*x + B*u}, @(x) C*x);
pidControl = PIDControl(k_p, k_i, k_d);
model = OFBControl(dynSys, pidControl);
simulator = Simulator(model);
simulator.propagate(0.01, 5, true, 1);
dynSys.defaultPlot();

rmpath(genpath('../core'))
rmpath(genpath('../common'))