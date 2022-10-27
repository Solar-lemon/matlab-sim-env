classdef Dyn6DOF < DynSystem
    properties
        m
        J
    end
    properties(Dependent)
        R
        v_i
    end
    methods
        function obj = Dyn6DOF(p_0, v_b_0, q_0, omega_0, m, J, name)
            arguments
                p_0, v_b_0, q_0, omega_0, m, J
                name = []
            end
            obj = obj@DynSystem(...
                {p_0, v_b_0, q_0, omega_0}, ...
                {'p', 'v_b', 'q', 'omega'}, ...
                {'f_b', 'm_b'}, [], [], name);
            obj.m = m;
            obj.J = J;

            function out = normalize(v)
                v_norm = vecnorm(v);
                if v_norm < 1e-6
                    out = zeros(size(v));
                else
                    out = v/v_norm;
                end
            end

            obj.stateVars{3}.attachCorrectionFun(@normalize);
        end

        % dynamic property
        function R_bi = get.R(obj)
            % rotation matrix representing the rotation from the inertial
            % fram to the body frame
            q = obj.state(3);
            R_bi = Dyn6DOF.qToR(q);
        end

        % dynamic property
        function out = get.v_i(obj)
            v_b = obj.state(2);
            R_ib = obj.R.';
            out = R_ib*v_b;
        end
    end
    methods(Access=protected)
        % implement
        function out = deriv_(obj, p, v_b, q, omega, f_b, m_b)
            R_bi = Dyn6DOF.qToR(q);
            R_ib = R_bi.';

            p_dot = R_ib*v_b;
            v_b_dot = -cross(omega, v_b) + 1/obj.m*f_b;

            Q = [-q(2), -q(3), -q(4);
                q(1), -q(4), q(3);
                q(4), q(1), -q(2);
                -q(3), q(2), q(1)];
            q_dot = 0.5*Q*omega;
            omega_dot = linsolve(obj.J, -cross(omega, obj.J*omega) + m_b);

            out = {p_dot, v_b_dot, q_dot, omega_dot};
        end

        % override
        function out = output_(obj)
            out = [obj.state(), {obj.R, obj.v_i}];
        end
    end
    methods(Static)
        function R_bi = qToR(q)
            eta = q(1);
            epsilon = q(2:4);
            S_epsilon = Orientation.hat(epsilon);
            R_bi = eye(3) - 2*eta*S_epsilon + 2*S_epsilon*S_epsilon;
        end
    end
end