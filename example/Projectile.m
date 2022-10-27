classdef Projectile < DynSystem
    properties
        mu
    end
    methods
        function obj = Projectile(p_0, v_0, mu)
            arguments
                p_0
                v_0
                mu = 0
            end
            obj = obj@DynSystem({p_0, v_0}, {'p', 'v'}, [], [], [], 'projectile');
            obj.mu = mu;
        end
    end
    methods(Access=protected)
        % implement
        function out = deriv_(obj, p, v)
            pDot = v;
            vDot = [0; -9.807] - obj.mu*vecnorm(v)*v;
            out = {pDot, vDot};
        end

        % implement
        function toStop = checkStopCondition_(obj)
            p = obj.state(1);
            p_y = p(2);
            toStop = (p_y < 0);
        end
    end
end