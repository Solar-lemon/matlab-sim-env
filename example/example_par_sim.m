clear all
clc
close all

addpath(genpath('../core'))

zetaArray = linspace(0.2, 1, 5);
omegaArray = linspace(1, 10, 10);

paramNames = {'zeta', 'omega'};
paramSets = List();
for i = 1:numel(zetaArray)
    for j = 1:numel(omegaArray)
        paramSets.append({zetaArray(i) omegaArray(j)});
    end
end
paramSets = paramSets.toCell();

parSimulator = ParallelSimulator(@simulationFun);
parSimulator.simulate(paramSets);
parSimulator.save('./data/parSim.hdf5')

data = parSimulator.get('zeta', 'omega', 'overshoot');

overshoot = data{3};
numColor = 16;
offset = 1;
c = overshoot - min(overshoot);
c = round((numColor - 1 - 2*offset)*c/max(c) + 1 + offset);

figure();
hold on
scatter3(data{1}, data{2}, data{3}, 30, c, 'filled')
view([30, 35])
xlabel("Zeta")
ylabel("Omega")
zlabel("Overshoot (%)")
grid on
box on
colorbar('Location', 'EastOutside')

rmpath(genpath('../core'))

function model = modelGenerator(zeta, omega)
model = SecondOrderLinSys([0; 0], zeta, omega);
end

function result = simulationFun(zeta, omega)
u_step = 1;

model = modelGenerator(zeta, omega);
verbose = false;
simulator = Simulator(model, verbose);
simulator.propagate(0.01, 100, true, u_step);

state = model.history('x');
overshoot = max(state(1, :) - u_step)/u_step*100;

result.keys = {'zeta', 'omega', 'overshoot'};
result.values = {zeta, omega, overshoot};
end
