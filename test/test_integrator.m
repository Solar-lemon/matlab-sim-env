clear all
clc
close all

addpath(genpath('../core/'))
addpath(genpath('../common/model'))

signalGenerator = SignalGenerator(@(t) 1/(1 + t)^2);
integrator = Integrator(0);
model = Sequential({signalGenerator, integrator});
simulator = Simulator(model);
simulator.propagate(0.01, 10, true);
integrator.defaultPlot();

rmpath(genpath('../core/'))
rmpath(genpath('../common/model'))
