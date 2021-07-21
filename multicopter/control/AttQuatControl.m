classdef AttQuatControl < BaseFunction
    % Ref: J. Carino, H. Abaunza and P. Castillo, 2015,
    % "Quadrotor Quaternion Control"
    properties
        J
        K
    end
    methods
        function obj = AttQuatControl(J, K)
            obj.J = J;
            obj.K = K;
        end
        
        % implement
        function tau = forward(obj, q, omega, q_d, omega_d)
            [a, phi] = Orientations.quatToAxisAngle(q);
            theta = a*phi;
            x = [theta; omega];
            
            [a_d, phi_d] = Orientations.quatToAxisAngle(q_d);
            theta_d = a_d*phi_d;
            x_d = [theta_d; omega_d];
            
            u = -obj.K*(x - x_d);
            tau = obj.J*u + cross(omega, obj.J*omega);
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