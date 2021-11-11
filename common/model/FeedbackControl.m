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
            
            obj.attachSimObjects({system, control});
        end
        
        % implement
        function forward(obj, r)
            if nargin < 2
                r = [];
            end
            y = obj.system.output;
            u = obj.control.forward(y, r);
            obj.system.forward(u);
        end
    end
end