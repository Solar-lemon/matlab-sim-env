clear
clc
close all

addpath(genpath('../core'))

derivFun = @(t, x) {-1/(1 + t)^2*x};
model = TimeVaryingDynSystem({1}, {'x'}, [], derivFun, []);
simulator = Simulator(model);
simulator.propagate(0.01, 10, true);
model.defaultPlot();

rmpath(genpath('../core'))