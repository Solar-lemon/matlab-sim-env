classdef BOMIACG < BaseFunction
    % Reference: H. Kim, Look Angle Constrained Impact Angle Control
    % Guidance Law for Homing Missiles With Bearings-Only Measurements,
    % 2018, IEEE Transactions on Aerospace and Electronic Systems
    properties
        % gamma_d: the desired final flight path angle of the missile
        % k_1, phi: design parameters for the sliding surface
        % 0 < k_1 < sigma_max, phi > 0
        % R_f: the acceptable maximum miss distance
        % k_2, a: a design parameter for the sliding mode control
        gamma_d
        k_1
        k_2
        R_f
        phi
        a = 0.1
    end
    methods
        function obj = BOMIACG(gamma_d, sigma_max, k_2, R_f, phi)
            obj.gamma_d = gamma_d;
            obj.k_1 = sigma_max - 0.01;
            obj.k_2 = k_2;
            obj.R_f = R_f;
            obj.phi = phi;
        end
        
        % implement
        function a_M = forward(obj, v_M, sigma_M, lam)
            e_1 = lam - obj.gamma_d;
            e_2 = sigma_M;
            s = e_2 - obj.k_1*obj.sigmoid(e_1);
            
            f_2 = (1 + obj.k_1*obj.sigmoidDerivative(e_1))*...
                abs(sin(sigma_M));
            a_M = -(v_M/obj.R_f*f_2 + obj.k_2)*v_M*tanh(obj.a*s);
        end
        
        function out = sigmoid(obj, x)
            out = x/sqrt(x^2 + obj.phi^2);
        end
        
        function out = sigmoidDerivative(obj, x)
            out = obj.phi^2/((x^2 + obj.phi^2)^(1.5));
        end
    end
end