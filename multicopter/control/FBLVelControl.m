classdef FBLVelControl < BaseFunction
    % Reference: H. Voos, "Nonlinear Control of a Quadrotor Micro-UAV using
    % Feedback-Linearization", Proceedings of the 2009 IEEE International
    % Conference on Mechatronics, 2009.
    properties
        m
        J
        k_p_att = [1600; 1600; 1600]
        k_d_att = [80; 80; 80]
        k_p_vel = [5; 5; 5]
    end
    methods
        function obj = FBLVelControl(m, J, k_p_att, k_d_att, k_p_vel)
            obj.m = m;
            obj.J = J;
            if nargin > 3
                obj.k_p_att = k_p_att;
                obj.k_d_att = k_d_att;
                obj.k_p_vel = k_p_vel;
            end
        end
        
        % implement
        function u = forward(obj, v, eta, omega, v_d)
            % v: velocity
            % eta: euler angles [phi; theta; psi]
            % omega: angular velocity
            % v_d: desired velocity\
            if nargin < 5
                v_d = zeros(3, 1);
            end
            u_tilde = obj.k_p_vel.*(v_d - v);
            
            u_t_1 = u_tilde(1);
            u_t_2 = u_tilde(2);
            u_t_3 = u_tilde(3);
            g = FlatEarthEnv.gravAccel;
            
            if abs(u_t_1) > 1e-4
                beta = -sign(u_t_1)/sqrt(...
                    1 + ((g - u_t_3)/u_t_1)^2);
                f = obj.m*sqrt(...
                    (u_t_1/beta)^2 + u_t_2^2);
                alpha = obj.m/f*u_t_2;
            else
                beta = 0;
                f = obj.m*sqrt(...
                    u_t_2^2 + (g - u_t_3)^2);
                alpha = obj.m/f*u_t_2;
            end
            phi_d = real(asin(alpha));
            theta_d = real(asin(beta));
            psi_d = 0;
            
            eta_d = [phi_d; theta_d; psi_d];
            u_star = obj.k_p_att.*(eta_d - eta) - obj.k_d_att.*omega;
            
            J_x = obj.J(1, 1);
            J_y = obj.J(2, 2);
            J_z = obj.J(3, 3);
            J_1 = (J_y - J_z)/J_x;
            J_2 = (J_z - J_x)/J_y;
            J_3 = (J_x - J_y)/J_z;
            
            p = omega(1);
            q = omega(2);
            r = omega(3);
            tau_x = J_x*(-q*r*J_1 + u_star(1));
            tau_y = J_y*(-p*r*J_2 + u_star(2));
            tau_z = J_z*(-p*q*J_3 + u_star(3));
            
            u = [f; tau_x; tau_y; tau_z];
        end
    end
end
                
