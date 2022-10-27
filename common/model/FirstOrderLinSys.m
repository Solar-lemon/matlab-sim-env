classdef FirstOrderLinSys < DynSystem
    properties
        A
        B
        tau
    end
    methods
        function obj = FirstOrderLinSys(x_0, tau, name)
            arguments
                x_0
                tau
                name = []
            end
            A = -1/tau;
            B = 1/tau;

            obj = obj@DynSystem({x_0}, {'x'}, {'u'}, ...
                @(x, u) {A*x + B*u}, [], name);
            obj.A = A;
            obj.B = B;
            obj.tau = tau;
        end
    end
    methods(Access=protected)
        % override
        function out = output_(obj)
            out = obj.state(1);
        end
    end
end