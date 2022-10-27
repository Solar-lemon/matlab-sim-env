classdef Differentiator < SimObject
    properties
        u_prev
        t_prev
    end
    methods
        function obj = Differentiator(interval, name)
            arguments
                interval = -1
                name = []
            end
            obj = obj@SimObject(interval, name);
        end
    end
    methods(Access=protected)
        function out = forward_(obj, u)
            if isempty(obj.u_prev)
                out = zeros(size(u));
            else
                out = (u - obj.u_prev)/(obj.time - obj.t_prev);
            end

            if obj.simClock.majorTimeStep
                obj.u_prev = u;
                obj.t_prev = obj.time;
            end
        end
    end
end