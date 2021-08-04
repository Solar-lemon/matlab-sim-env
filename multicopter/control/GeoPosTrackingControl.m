classdef GeoPosTrackingControl < BaseFunction
    % Ref: T. Lee, M. Leok and N. H. McClamroch, "Geometric tracking
    % control of a quadrotor UAV on SE(3)", 2010.
    properties
        m
        k_x
        k_v
        e3 = [0; 0; 1];
        gravAccel
    end
    methods
        function obj = GeoPosTrackingControl(m, k_x, k_v)
            obj.m = m;
            obj.k_x = k_x;
            obj.k_v = k_v;
            obj.gravAccel = FlatEarthEnv.gravAccel*obj.e3;
        end
        
        % implement
        function out = forward(obj, p, v, R, var_x_d, var_phi_d)
            % p: position, 3x1 vector
            % v: velocity, 3x1 vector
            % R: rotation, 3x3 matrix
            % var_x_d: DerivVariable of order 3
            % var_phi_d: DerivVariable of order 1
            % f: thrust, numeric
            % R_d: desired rotation, 3x3 matrix
            % omega_d: desired angluar velocity, 3x1 vector
            e_x = p - var_x_d.deriv(0);
            e_v = v - var_x_d.deriv(1);
            
            F_d = obj.m*(obj.k_x*e_x + obj.k_v*e_v + ...
                obj.gravAccel - var_x_d.deriv(2));
            f = F_d.'*(R*obj.e3);
            
            a = obj.gravAccel - (f/obj.m)*R*obj.e3;
            e_a = a - var_x_d.deriv(2);
            F_d_dot = obj.m*(obj.k_x*e_v + obj.k_v*e_a - var_x_d.deriv(3));
            
            var_F_d = DerivVariable(F_d, F_d_dot);
            var_z_B_d = normalize(var_F_d);
            var_x_C_d = [...
                cos(var_phi_d);
                sin(var_phi_d);
                0];
            var_y_B_d = normalize(cross(var_z_B_d, var_x_C_d));
            var_x_B_d = cross(var_y_B_d, var_z_B_d);
            var_R_d = [var_x_B_d, var_y_B_d, var_z_B_d];
            
            out = {f, var_R_d};
        end
    end
end