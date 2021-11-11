classdef IACCGEngagement < Engagement2dim
    properties
        iaccg
        iaccgZOH
    end
    methods
        function obj = IACCGEngagement(missile, target, gamma_imp, sigma_d)
            sigma_max = missile.fovLimit;
            if nargin < 4 || isempty(sigma_d)
                sigma_d = sigma_max - 1e-3;
            end
            
            obj = obj@Engagement2dim(missile, target);
            
            gamma_T = target.state(4);
            v_M = missile.speed;
            v_T = target.speed;
            
            K = 1.5;
            N = 3;
            obj.iaccg = IACCG(gamma_imp, gamma_T, v_M, v_T, K, sigma_d, N); 
            obj.iaccgZOH = ZeroOrderHold(...
                obj.iaccg, 1/40); % 40 Hz
            
            obj.attachSimObjects({obj.iaccgZOH});
        end
        
        % implement
        function forward(obj)
            forward@Engagement2dim(obj);
            v_M = obj.missile.speed;
            sigma = obj.missile.lookAngle();
            lam = obj.kinematics.losAngle;
            omega = obj.kinematics.losRate;
            
            a_M = obj.iaccgZOH.forward(v_M, sigma, lam, omega);
            obj.missile.forward([0; a_M]);
        end
        
        function out = impactAngle(obj)
            x_M = obj.missile.history('state');
            x_T = obj.target.history('state');
            
            p_M = x_M(1:2, :);
            p_T = x_T(1:2, :);
            r = vecnorm(p_M - p_T, 2, 1);
            
            [~, index] = min(r);
            
            gamma_M = x_M(4, index);
            gamma_T = x_T(4, index);
            
            out = gamma_T - gamma_M;
        end
        
        % override
        function report(obj)
            report@Engagement2dim(obj);
            fprintf("[Engagement] Impact angle: %.2f [deg] \n", rad2deg(obj.impactAngle()))
            obj.iaccg.report();
        end
    end
end