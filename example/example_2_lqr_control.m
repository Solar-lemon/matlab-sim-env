clear
clc
close all

addpath(genpath('../core'))

model = ClosedLoopLinSystem();
simulator = Simulator(model);
simulator.propagate(0.01, 10, true);
model.linSystem.defaultPlot();

rmpath(genpath('../core'))