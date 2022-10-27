clear all
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common/model'))

signalGenerator = SignalGenerator(@(t) 1 - exp(-0.2*t));
differentiator = Differentiator();
scope = Scope({'u'});

model = Sequential({signalGenerator, differentiator, scope});
simulator = Simulator(model);
simulator.propagate(0.01, 10, true);

t = scope.history('t');
y_numerical = scope.history('u');
y_analytic = 0.2*exp(-0.2*t);

figure();
hold on
plot(t, y_numerical, 'DisplayName', 'Numerical')
plot(t, y_analytic, 'DisplayName', 'Analytic')
xlabel("Time (s)")
ylabel("Derivative")
grid on
legend()

rmpath(genpath('../core'))
rmpath(genpath('../common/model'))