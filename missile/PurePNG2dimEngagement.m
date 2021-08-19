classdef PurePNG2dimEngagement < Engagement2dim
    properties
        purePng
    end
    methods
        function obj = PurePNG2dimEngagement(missile, target)
            if nargin < 1
                missile = PlanarMissile3dof(...
                    [-5E3; 3E3; 300; deg2rad(-5)]);
                target = PlanarStationaryVehicle3dof([0; 0]);
            end
            obj = obj@Engagement2dim(missile, target);
            
            obj.purePng = DiscreteFunction(PurePNG2dim(3), 1/40); % 40 Hz
            obj.attachDiscSystems({obj.purePng});
        end
        
        % implement
        function forward(obj)
            forward@Engagement2dim(obj);
            v_M = obj.missile.state(3);
            omega = obj.kinematics.losRate;
            
            a_M = obj.purePng.forward(v_M, omega);
            obj.missile.forward([0; a_M]);
        end
    end
end