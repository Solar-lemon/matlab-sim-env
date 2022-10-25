classdef PIController < SimObject
    properties
        k_p
        k_i
    end
    methods
        function obj = PIController(k_p, k_i)
            obj = obj@SimObject();
            obj.k_p = k_p;
            obj.k_i = k_i;

            obj.addStateVars({'e_i'}, {0});
        end
    end
    methods(Access=protected)
        % implement
        function u_pi = forward_(obj, e)
            obj.stateVars{1}.setDeriv(e);
            
            e_i = obj.state(1);
            u_pi = obj.k_p*e + obj.k_i*e_i;
        end
    end
end