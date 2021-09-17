classdef Integrator < DynSystem
    methods
        function obj = Integrator(x_0)
            % x_0: initial value of the integrator
            derivFun = @(x, u) u;
            obj = obj@DynSystem(x_0, derivFun);
        end
    end
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for Integrator ==\n")
            model = Integrator(0);
            fun = @(u) 1/(1 + u)^2;
            Simulator(model).propagate(0.01, 10, true, fun);
            model.plot();
        end
    end
end