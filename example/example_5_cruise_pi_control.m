addpath(genpath('../core'))
addpath(genpath('./'))

clear
clc
close all

zeta = 1;
omegaList = {0.05, 0.1, 0.2};
v_r = 5;
theta = 0.04; % 4% slope

dataList = List();

for i = 1:numel(omegaList)
    omega = omegaList{i};
    k_p = 2*zeta*omega - 0.02;
    k_i = omega^2;

    car = CCCar(k_p, k_i, v_r);
    simulator = Simulator(car);
    simulator.propagate(0.01, 100, true, v_r, theta);

    data = car.history('t', 'e', 'u');
    dataList.append(data);
end

figure();
lines = {':', '-', '--'};
for i = 1:numel(omegaList)
    data = dataList.get(i);
    [t, e, u] = data{:};

    subplot(2, 1, 1)
    hold on
    plot(t, e, 'Color', 'b', 'LineStyle', lines{i});
    
    subplot(2, 1, 2)
    hold on
    plot(t, u, 'Color', 'b', 'LineStyle', lines{i});
end

subplot(2, 1, 1)
xlabel("Time")
ylabel("Velocity error")
xticks(linspace(0, 100, 11))
yticks(linspace(0, 4, 5))

subplot(2, 1, 2)
xlabel("Time")
ylabel("Control signal")
xticks(linspace(0, 100, 11))
yticks(linspace(0, 0.6, 7))

rmpath(genpath('../core'))
rmpath(genpath('./'))