classdef FeedbackControl < MultipleSystem
    properties
        system
        control
    end
    methods
        function obj = FeedbackControl(system, control)
            obj = obj@MultipleSystem();
            obj.system = system;
            obj.control = control;
            
            obj.attachDynSystems({system});
            if isa(control, 'DiscreteFunction')
                obj.attachDiscSystems({control});
            end
        end
        
        % implement
        function forward(obj, r)
            if nargin < 2
                r = [];
            end
            x = obj.system.output;
            u = obj.control.forward(x, r);
            obj.system.forward(u);
        end
    end
end