clear
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

fprintf("== Test for LinearQuadraticRegulator ==\n")

zeta  = 0.1;
omega = 1;
A = [0, 1;
    -omega^2, -2*zeta*omega];
B = [0; omega^2];
Q = diag([1, 1]);
R = 1;
K_reg = LinearQuadraticRegulator.gain(A, B, Q, R);

linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
lqrControl = LinearQuadraticRegulator(K_reg);

model = FeedbackControl(linearSystem, lqrControl);
Simulator(model).propagate(0.01, 10, true);
linearSystem.plot();

rmpath(genpath('../core'))
rmpath(genpath('../common'))
