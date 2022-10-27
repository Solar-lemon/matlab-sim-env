classdef CCCar < SimObject
    properties
        velDyn
        piControl
    end
    methods
        function obj = CCCar(k_p, k_i, v_0)
            function out = derivFun(v, u, theta)
                c = 0.02;
                g = 9.81;

                vDot = -c*v + u - g*theta;
                out = {vDot};
            end

            obj.velDyn = DynSystem({v_0}, {'v'}, {'u', 'theta'}, @derivFun, [], 'velDyn');
            obj.piControl = PIController(k_p, k_i);

            obj.addSimObjs({obj.velDyn, obj.piControl});
        end
    end
    methods(Access=protected)
        % implement
        function out = forward_(obj, v_r, theta)
            % tracking error
            v = obj.velDyn.state(1);
            e = v_r - v;

            % PI control input
            u_pi = obj.piControl.forward(e);
            
            % update dynamic
            obj.velDyn.forward(u_pi, theta);

            % log velocity error and control signal
            obj.logger.append({'t', 'e', 'u'}, {obj.time, e, u_pi});

            out = [];
        end
    end
end