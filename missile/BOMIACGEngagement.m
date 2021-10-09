classdef BOMIACGEngagement < Engagement2dim
    properties
        bomiaccg
    end
    methods
        function obj = BOMIACGEngagement(missile, target, gamma_d)
            obj = obj@Engagement2dim(missile, target);
            
            sigma_max = missile.fovLimit;
            obj.bomiaccg = DiscreteFunction(...
                BOMIACG(gamma_d, sigma_max, 10, 0.5, 0.15), 1/40); % 40Hz
            
            obj.attachDiscSystems({obj.bomiaccg});
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
            rangeList = obj.history('r');
            [~, index] = min(rangeList);
            
            state_M = obj.missile.history('state');
            out = state_M(4, index);
        end
        
        % override
        function report(obj)
            report@Engagement2dim(obj);
            fprintf("[Engagement] Impact angle: %.2f [deg] \n",...
                rad2deg(obj.impactAngle()))
        end
    end
end