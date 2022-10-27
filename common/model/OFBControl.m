classdef OFBControl < SimObject
    properties
        system
        control
    end
    methods
        function obj = OFBControl(system, control, interval, name)
            arguments
                system
                control
                interval = -1;
                name = [];
            end
            obj = obj@SimObject(interval, name)
            obj.system = system;
            obj.control = control;

            obj.addSimObjs({system, control});
        end
    end
    methods(Access=protected)
        % implement
        function out = forward_(obj, varargin)
            y = obj.system.output;
            if isnumeric(y)
                u_fb = obj.control.forward(y, varargin{:});
            elseif iscell(y)
                u_fb = obj.control.forward(y{:}, varargin{:});
            else
                error('ValueError')
            end
            out = obj.system.forward(u_fb);
        end
    end
end