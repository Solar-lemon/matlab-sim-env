clear all
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

m = 1;
w = 0.3;
h = 0.1;
d = 0.5;
J = diag([1/12*m*(h^2 + d^2), 1/12*m*(w^2 + h^2), 1/12*m*(w^2 + d^2)]);

p_0 = zeros(3, 1);
v_b_0 = zeros(3, 1);
q_0 = [1; 0; 0; 0];
omega_0 = zeros(3, 1);

dyn6dof = Dyn6DOF(p_0, v_b_0, q_0, omega_0, m, J);
source = SignalGenerator(@forceMoment);
model = Sequential({source, dyn6dof});
simulator = Simulator(model);
simulator.propagate(0.01, 5, true);
dyn6dof.defaultPlot();

rmpath(genpath('../core'))
rmpath(genpath('../common'))

function out = forceMoment(t)
if t < 2
    f_b = [0; 0; 1];
    m_b = [0.015; 0; 0];
else
    f_b = zeros(3, 1);
    m_b = zeros(3, 1);
end
out = {f_b, m_b};
end