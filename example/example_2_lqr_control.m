clear all
clc
close all

addpath(genpath('../core'))

model = ClosedLoopLinSystem();
simulator = Simulator(model);
simulator.propagate(0.01, 400, true);
model.linSystem.defaultPlot();

rmpath(genpath('../core'))