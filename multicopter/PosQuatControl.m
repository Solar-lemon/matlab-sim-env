classdef PosQuatControl < BaseFunction
    % Ref: J. Carino, H. Abaunza and P. Castillo, 2015,
    % "Quadrotor Quaternion Control"
    properties
        m
        K
        grav
        n = [0; 0; -1];
    end
    methods
        function obj = PosQuatControl(m, K, grav)
            if nargin < 3
                grav = 9.805*[0; 0; 1];
            end
            obj.m = m;
            obj.K = K;
            obj.grav = grav;
        end
        
        % implement
        function [f, q_d, omega_d] = forward(obj, p, v, p_d, v_d)
            x = [p; v];
            x_d = [p_d; v_d];
            u = -obj.K*(x - x_d);
            
            u_pd = u - obj.grav;
            f = obj.m*norm(u_pd);
            
            r_d = [...
                obj.n.'*u_pd + norm(u_pd);
                cross(obj.n, u_pd)];
            q_d = r_d / norm(r_d);
            
            u_pd_dot = -obj.K*[v; u];
            r_d_dot = [...
                obj.n.'*u_pd_dot + u_pd.'*u_pd_dot/norm(u_pd);
                cross(obj.n, u_pd_dot)];
            q_d_dot = r_d_dot/norm(r_d) + r_d*(-r_d.'*r_d_dot/norm(r_d)^3);
            
            omega_d = 2*conj(quaternion(q_d.'))*quaternion(q_d_dot.');
            omega_d = compact(omega_d);
            omega_d = omega_d(2:4).';
        end
    end
    methods(Static)
        function K = gain(Q, R)
            A = [zeros(3, 3), eye(3);
                zeros(3, 3), zeros(3, 3)];
            B = [zeros(3, 3); eye(3)];
            K = lqr(A, B, Q, R, []);
        end
    end
end