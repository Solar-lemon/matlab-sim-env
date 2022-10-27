classdef PIDControl < SimObject
    properties
        k_p
        k_i
        k_d
        windupLimit

        e_prev
        t_prev
    end
    methods
        function obj = PIDControl(k_p, k_i, k_d, windupLimit, interval, name)
            arguments
                k_p
                k_i
                k_d
                windupLimit = []
                interval = -1
                name = []
            end
            obj = obj@SimObject(interval, name);
            obj.addStateVars({'e_i'}, {zeros(size(k_p))});

            obj.k_p = k_p;
            obj.k_i = k_i;
            obj.k_d = k_d;
            if windupLimit
                obj.stateVars{1}.attachCorrection(@obj.clipWindup);
            end
        end

        function out = clipWindup(obj, e_i)
            out = min(max(e_i, obj.windupLimit), -obj.windupLimit);
        end
    end
    methods(Access=protected)
        function u_pid = forward_(obj, y, r)
            % y: output, r: reference
            if nargin < 2
                r = zeros(size(y));
            end
            e = r - y;

            obj.stateVars{1}.setDeriv(e);
            e_i = obj.state(1);
            if obj.e_prev
                e_d = (e - obj.e_prev)/(obj.time - obj.t_prev);
            else
                e_d = zeros(size(e));
            end
            u_pid = obj.k_p*e + obj.k_i*e_i + obj.k_d*e_d;

            if obj.simClock.majorTimeStep
                obj.e_prev = e;
                obj.t_prev = obj.time;
            end
        end
    end
end