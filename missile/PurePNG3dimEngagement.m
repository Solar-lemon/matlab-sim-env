classdef PurePNG3dimEngagement < Engagement3dim
    properties
        purePng
    end
    methods
        function obj = PurePNG3dimEngagement(missile, target)
            if nargin < 1
                missile = Missile3dof(...
                    [-5E3; -1E3; -5E3; 300; deg2rad(-5); 0]);
                target = StationaryVehicle3dof([0; 0; 0]);
            end
            obj = obj@Engagement3dim(missile, target);
            
            obj.purePng = DiscreteFunction(PurePNG3dim(3), 1/40); % 40 Hz
            obj.attachDiscSystems({obj.purePng});
        end
        
        % implement
        function forward(obj)
            forward@Engagement3dim(obj);
            
            R_VL = obj.missile.RLocalToVelocity;
            v_M = obj.missile.vel;
            omega = obj.kinematics.losRate;
            
            a_M = obj.purePng.forward(R_VL, v_M, omega);
            obj.missile.forward(a_M);
            obj.target.forward();
            
            obj.logger.forward(...
                {'time', 'lookAngle', 'losRate', 'range'},...
                {obj.simClock.time, sigma, omega, r});
        end
    end
end