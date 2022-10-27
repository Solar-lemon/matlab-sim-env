classdef SecondOrderLinSys < DynSystem
    properties
        A
        B
        zeta
        omega
    end
    methods
        function obj = SecondOrderLinSys(x_0, zeta, omega, name)
            arguments
                x_0
                zeta
                omega
                name = []
            end
            A = [0, 1; -omega^2, -2*zeta*omega];
            B = [0; omega^2];

            obj = obj@DynSystem({x_0}, {'x'}, {'u'}, ...
                @(x, u) {A*x + B*u}, [], name);
            obj.A = A;
            obj.B = B;
            obj.zeta = zeta;
            obj.omega = omega;
        end
    end
    methods(Access=protected)
        % override
        function out = output_(obj)
            x = obj.state(1);
            out = x(1);
        end
    end
end