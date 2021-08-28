classdef ModifiedDPPEngagement < Engagement2dim
    properties
        modifiedDPP
    end
    methods
        function obj = ModifiedDPPEngagement(missile, target)
            obj = obj@Engagement2dim(missile, target);
            
            obj.modifiedDPP = DiscreteFunction(...
                ModifiedDPP(2.0), 1/40); % 40 Hz
            
            obj.attachDiscSystems({obj.modifiedDPP});
        end
        
        % implement
        function forward(obj, sigma_d)
            if nargin < 2 || isempty(sigma_d)
                sigma_d = 0;
            end
            forward@Engagement2dim(obj);
            v_M = obj.missile.speed;
            omega = obj.kinematics.losRate;
            sigma = obj.missile.lookAngle();
            
            a_M = obj.modifiedDPP.forward(v_M, omega, sigma, sigma_d);
            obj.missile.forward([0; a_M]);
        end
    end
end