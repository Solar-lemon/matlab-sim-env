clear
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))
set(0,'DefaultFigureWindowStyle','docked')

fprintf('== Test for SecondOrderDynSystem == \n')

zeta = 0.5;
omega = 1;

dt = 0.01;
finalTime = 10;
u_step = 1;

% Using a function handle
fprintf("Using a function handle \n")
tic
A = [...
    0, 1;
    -omega^2, -2*zeta*omega];
B = [0; omega^2];
derivFun = @(x, u) A*x + B*u;
system1 = DynSystem([0; 0], derivFun);
Simulator(system1).propagate(dt, finalTime, true, u_step);
elapsedTime = toc;

fprintf("Elapsed time: %.2f [s] \n\n", elapsedTime);

% Using a BaseFunction object
fprintf("Using a BaseFunction object \n")
tic
system2 = DynSystem([0; 0], SecondOrderDynFun(zeta, omega));
Simulator(system2).propagate(dt, finalTime, true, u_step);
elapsedTime = toc;

fprintf("Elapsed time: %.2f [s] \n\n", elapsedTime);

% Using class inheritance
fprintf("Using class inheritance \n")
tic
system3 = SecondOrderDynSystem([0; 0], zeta, omega);
Simulator(system3).propagate(dt, finalTime, true, u_step);
elapsedTime = toc;

fprintf("Elapsed time: %.2f [s] \n\n", elapsedTime);

fig1 = figure();
sgtitle('function handle')
system1.plot(fig1);

fig2 = figure();
sgtitle('BaseFunction')
system2.plot(fig2);

fig3 = figure();
sgtitle('class inheritance')
system3.plot(fig3);

% Time varying input test
fprintf("Time varying input test \n")
u_varying = @(t) sin(2*pi*t/10);
tic
system4 = SecondOrderDynSystem([0; 0], zeta, omega);
Simulator(system4).propagate(dt, finalTime, true, u_varying);
elapsedTime = toc;

fprintf("Elapsed time: %.2f [s] \n\n", elapsedTime);

fig4 = figure();
sgtitle('time varying input')
system4.plot(fig4);

rmpath(genpath('../core'))
rmpath(genpath('../common'))
set(0,'DefaultFigureWindowStyle','normal')