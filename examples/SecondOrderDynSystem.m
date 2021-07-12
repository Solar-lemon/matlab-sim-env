classdef SecondOrderDynSystem < DynSystem
    properties
        zeta
        omega
        A
        B
    end
    methods
        function obj = SecondOrderDynSystem(initialState, zeta, omega)
            obj = obj@DynSystem(initialState);
            obj.zeta = zeta;
            obj.omega = omega;
            obj.A = [...
                0, 1;
                -omega^2, -2*zeta*omega];
            obj.B = [0; omega^2];
        end
        
        % override
        function out = derivative(obj, x, u)
            out = obj.A*x + obj.B*u;
        end
    end
end