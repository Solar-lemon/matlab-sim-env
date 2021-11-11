clear
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

signalGenerator = SignalGenerator(@(t) sin(0.2*pi*t));

zeta = 0.5;
omega = 1;
A = [...
    0, 1;
    -omega^2, -2*zeta*omega];
B = [0; omega^2];
linearSys = DynSystem([0; 0], @(x, u) A*x + B*u);

model = Sequential({signalGenerator, linearSys});
simulator = Simulator(model);
simulator.propagate(0.01, 10);
linearSys.plot();