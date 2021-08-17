classdef SecondOrderDyn < DynSystem
    properties
        zeta
        omega
    end
    methods
        function obj = SecondOrderDyn(initialState, zeta, omega)
            % initialState: 2x1 vector
            obj = obj@DynSystem(...
                initialState, SecondOrderDynFun(zeta, omega));
            obj.zeta = zeta;
            obj.omega = omega;
        end
        
        % implement
        function out = output(obj)
            out = obj.state(1);
        end
    end
end