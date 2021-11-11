classdef BOMIACGEngagement < Engagement2dim
    properties
        bomiaccg
    end
    methods
        function obj = BOMIACGEngagement(missile, target, gamma_d)
            obj = obj@Engagement2dim(missile, target);
            
            sigma_max = missile.fovLimit;
            obj.bomiaccg = ZeroOrderHold(...
                BOMIACG(gamma_d, sigma_max, 10, 0.5, 0.15), 1/40); % 40Hz
            
            obj.attachSimObjects({obj.bomiaccg});
        end
        
        % implement
        function forward(obj)
            forward@Engagement2dim(obj);
            v_M = obj.missile.speed;
            sigma_M = obj.missile.lookAngle();
            lam = obj.kinematics.losAngle;
            
            a_M = obj.bomiaccg.forward(v_M, sigma_M, lam);
            obj.missile.forward([0; a_M]);
        end
        
        function out = impactAngle(obj)
            x_M = obj.missile.history('state');
            x_T = obj.target.history('state');
            
            p_M = x_M(1:2, :);
            p_T = x_T(1:2, :);
            r = vecnorm(p_M - p_T, 2, 1);
            
            [~, index] = min(r);
            
            out = x_M(4, index);
        end
        
        % override
        function report(obj)
            report@Engagement2dim(obj);
            fprintf("[Engagement] Impact angle: %.2f [deg] \n",...
                rad2deg(obj.impactAngle()))
        end
    end
end