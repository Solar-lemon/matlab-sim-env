classdef IACCGEngagement < Engagement2dim
    properties
        iaccg
    end
    methods
        function obj = IACCGEngagement(missile, target, gamma_imp)
            obj = obj@Engagement2dim(missile, target);
            
            gamma_T = target.state(4);
            v_M = missile.speed;
            v_T = target.speed;
            
            K = 1.5;
            sigma_max = obj.missile.fovLimit;
            N = 3;
            obj.iaccg = DiscreteFunction(...
                IACCG(gamma_imp, gamma_T, v_M, v_T, K, sigma_max, N), 1/40); % 40 Hz
            
            obj.attachDiscSystems({obj.iaccg});
        end
        
        % implement
        function forward(obj)
            forward@Engagement2dim(obj);
            v_M = obj.missile.speed;
            sigma = obj.missile.lookAngle();
            lam = obj.kinematics.losAngle;
            omega = obj.kinematics.losRate;
            
            a_M = obj.iaccg.forward(v_M, sigma, lam, omega);
            obj.missile.forward([0; a_M]);
        end
        
        function out = impactAngle(obj)
            rangeList = obj.historyByVarNames('r');
            [~, index] = min(rangeList);
            
            state_M = obj.missile.history{2};
            state_T = obj.target.history{2};
            
            gamma_M = state_M(4, index);
            gamma_T = state_T(4, index);
            
            out = gamma_T - gamma_M;
        end
        
        % override
        function report(obj)
            report@Engagement2dim(obj);
            fprintf("[Engagement] Impact angle: %.2f [deg] \n", rad2deg(obj.impactAngle()))
        end
    end
end