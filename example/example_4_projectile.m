clear
clc
close all

addpath(genpath('../core'))

keys = {'no drag', 'air'};
muList = {0, 0.0214};
dataList = List();

theta_0 = deg2rad(30);
p_0 = [0; 0];
v_0 = [20*cos(theta_0); 20*sin(theta_0)];

for i = 1:numel(keys)
    key = keys{i};
    mu = muList{i};
    projectile = Projectile(p_0, v_0, mu);
    simulator = Simulator(projectile);
    simulator.propagate(0.01, 10, true);

    data = projectile.history('t', 'p', 'v');
    dataList.append(data);
end

colors = dictionary('no drag', 'k', 'air', 'b');
figure();

subplot(3, 1, 1)
hold on
for i = 1:numel(keys)
    key = keys{i};
    data = dataList.get(i);
    [t, p, v] = data{:};

    plot(p(1, :), p(2, :), 'Color', colors(key), 'DisplayName', key);
    xlabel("Distance (m)")
    ylabel("Height (m)")
    title("Trajectory")
    grid on
    legend()
end

subplot(3, 1, 2)
hold on
for i = 1:numel(keys)
    key = keys{i};
    data = dataList.get(i);
    [t, p, v] = data{:};
    
    plot(t, v(1, :), 'Color', colors(key), 'DisplayName', key);
    xlabel("Time (s)")
    ylabel("v_x (m/s)")
    title("Horizontal velocity")
    grid on
    legend()
end

subplot(3, 1, 3)
hold on
for i = 1:numel(keys)
    key = keys{i};
    data = dataList.get(i);
    [t, p, v] = data{:};
    
    plot(t, v(2, :), 'Color', colors(key), 'DisplayName', key);
    xlabel("Time (s)")
    ylabel("v_y (m/s)")
    title("Vertical velocity")
    grid on
    legend()
end

rmpath(genpath('../core'))