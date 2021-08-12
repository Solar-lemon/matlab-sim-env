classdef FirstOrderDyn < DynSystem
    properties
        tau
    end
    methods
        function obj = FirstOrderDyn(initialState, tau)
            % initialState: 1x1 vector (scalar)
            obj = obj@DynSystem(initialState, FirstOrderDynFun(tau));
            obj.tau = tau;
        end
        
        % implement
        function out = output(obj)
            out = obj.state(1);
        end
    end
end