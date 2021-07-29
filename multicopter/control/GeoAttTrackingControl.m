classdef GeoAttTrackingControl < BaseFunction
    % Ref: T. Lee, M. Leok and N. H. McClamroch, "Geometric tracking
    % control of a quadrotor UAV on SE(3)", 2010.
    properties
        J
        k_R
        k_omega
    end
    methods
        function obj = GeoAttTrackingControl(J, k_R, k_omega)
            obj.J = J;
            obj.k_R = k_R;
            obj.k_omega = k_omega;
        end
        
        % implement
        function tau = forward(obj, R, omega, R_d, omega_d, omega_d_dot)
            if nargin < 6
                omega_d_dot = zeros(3, 1);
            end
            e_R = 1/2*So3Algebra(R_d.'*R - R.'*R_d).vector;
            e_omega = omega - R.'*R_d*omega_d;
            
            tau = -obj.k_R*e_R - obj.k_omega*e_omega + cross(omega, obj.J*omega) ...
                - obj.J*(...
                So3Algebra(omega).matrix*(R.')*R_d*omega_d ...
                - R.'*R_d*omega_d_dot);
        end
    end
    
    methods(Static)
        function [omega_d, omega_d_dot] = rotationToAngVel(R_d, R_d_dot, R_d_2dot)
            omega_d = So3Algebra(R_d.'*R_d_dot).vector;
            omega_d_dot = So3Algebra(R_d_dot.'*R_d_dot + R_d.'*R_d_2dot).vector;
        end
        
        function [Psi, e_R] = attitudeError(R, R_d)
            Psi = 1/2*trace(eye(3) - R_d.'*R);
            if nargout > 1
                e_R = 1/2*So3Algebra(R_d.'*R - R.'*R_d).vector;
            end
        end
    end
end