clear all
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

zeta = 0.1;
omega = 1;
A = [0, 1; -omega^2, -2*zeta*omega];
B = [0; omega^2];
K = [0.4142, 1.1669];

linSystem = DynSystem({[0; 1]}, {'x'}, {'u'}, ...
    @(x, u) {A*x + B*u}, [], 'linSystem');
control = StaticObject(@(x) -K*x, -1);
model = FeedbackControl(linSystem, control); % Closed-loop system

simulator = Simulator(model);
simulator.propagate(0.01, 10, true)
linSystem.defaultPlot();

rmpath(genpath('../core'))
rmpath(genpath('../common'))