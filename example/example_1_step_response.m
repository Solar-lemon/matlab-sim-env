clear all
clc
close all

addpath(genpath('../core'))

model = DynSystem({[0; 0]}, {'x'}, {'u'}, @derivFun, [], 'linSystem');
simulator = Simulator(model);
simulator.propagate(0.01, 10, true, 1);

t = model.history('t');
x = model.history('x');
u = model.history('u');

figure();
hold on
for i = 1:2
    plot(t, x(i, :), 'DisplayName', strcat('x_', num2str(i)))
end
xlabel("Time (s)")
ylabel("x")
grid on
legend()

figure();
hold on
plot(t, u, 'DisplayName', 'u')
xlabel("Time (s)")
ylabel("u")
grid on
legend()

rmpath(genpath('../core'))

function out = derivFun(x, u)
omega = 1;
zeta = 0.8;
A = [0, 1; -omega^2, -2*zeta*omega];
B = [0; omega^2];
xDot = A*x + B*u;
out = {xDot};
end