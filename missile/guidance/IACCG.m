classdef IACCG < BaseFunction
    properties
        % gamma_M_f: final flight path angle of the missile (impact angle)
        % v_M: speed of the missile
        % v_T: speed of the target
        % lam_s: switching condition for LOS angle
        % K: look angle control gain
        % sigma_d: look angle control command
        % N: guidance gain for PNG
        gamma_imp
        gamma_T
        v_M
        v_T
        lam_s
        lam_f
        K
        sigma_d
        N
    end
    methods
        function obj = IACCG(gamma_imp, gamma_T, v_M, v_T, K, sigma_max, N)
            % gamma_imp: impact angle
            gamma_M_f = gamma_T - gamma_imp;
            eta = IACCG.speedRatio(v_M, v_T);
            sigma_d = min(acos(2*eta), sigma_max) - 1e-3;
            lam_s = IACCG.switchCond(N, gamma_M_f, gamma_T, eta, sigma_d);
            
            obj.gamma_imp = gamma_imp;
            obj.gamma_T = gamma_T;
            obj.v_M = v_M;
            obj.v_T = v_T;
            obj.lam_s = lam_s;
            obj.K = K;
            obj.sigma_d = sigma_d;
            obj.N = N;
        end
        
        % implement
        function a_M = forward(obj, v_M, sigma, lam, omega)
            % v_M: speed of the missile
            % sigma: look angle
            % omega: LOS rate
            if abs(lam) < abs(obj.lam_s)
                a_M = v_M*(omega + obj.K*(obj.sigma_d - sigma));
            else
                a_M = obj.N*v_M*omega;
            end
        end
    end
    
    methods(Static)
        function eta = speedRatio(v_M, v_T)
            % eta: ratio of speeds (eta = v_T/v_M)
            eta = v_T/v_M;
        end
        
        function lam_s = switchCond(N, gamma_M_f, gamma_T, eta, sigma_s)
            lam_f = atan(...
                (sin(gamma_M_f) - eta*sin(gamma_T)) / ...
                (cos(gamma_M_f) - eta*cos(gamma_T)));
            lam_s = N/(N - 1)*(lam_f - (gamma_M_f - sigma_s)/N);
            fprintf("[IACCG] The swithing value for LOS angle is: %.2f [deg] \n", rad2deg(lam_s))
        end
    end
end