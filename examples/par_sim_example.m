clear
clc
close all

addpath(genpath('../core'))
addpath(genpath('../common'))

fprintf("== Test for ParallelSimulator ==\n")
zetaList = 0.2:0.2:1.0;
omegaList = 1:10;

parSimulator = ParallelSimulator();
parSimulator.attachParamLists(zetaList, omegaList);
parSimulator.attachSimulationFun(@simulationFun);
parSimulator.simulateSingle(0.4, 1);
parSimulator.simulate();
parSimulator.save();

data = parSimulator.get({'zeta', 'omega', 'overshoot'});
[zeta, omega, overshoot] = data{:};
numColor = 16;
offset = 1;
c = overshoot - min(overshoot);
c = round((numColor - 1 - 2*offset)*c/max(c) + 1 + offset);

figure();
hold on
scatter3(zeta, omega, overshoot, 30, c, 'filled')
view([30, 35])
xlabel('Zeta')
ylabel('Omega')
zlabel('Overshoot (%)')
grid on
box on
colorbar('Location', 'EastOutside')

rmpath(genpath('../core'))
rmpath(genpath('../common'))

function [simData, model] = simulationFun(i, zeta, omega)
model = SecondOrderDynSystem([0; 0], zeta, omega);
model.name = ['model_', num2str(i)];

u_step = 1;
Simulator(model).propagate(0.01, 100, true, u_step);
stateList = model.history('state');
overshoot = max(stateList(1, :) - u_step)/u_step*100;

simData.zeta = zeta;
simData.omega = omega;
simData.overshoot = overshoot;
end