classdef PlanarMissile3dof < PlanarManeuvVehicle3dof
    properties
        fovLimit = inf;
        engKinematics
    end
    methods
        function obj = PlanarMissile3dof(initialState)
            obj = obj@PlanarManeuvVehicle3dof(initialState);
            obj.name = "planarMissile3dof";
        end
        
        function attachEngKinematics(obj, engKinematics)
            obj.engKinematics = engKinematics;
        end
        
        % implement
        function [toStop, flag] = checkStopCondition(obj)
            toStop = false;
            if obj.isFallenDown()
                toStop = true;
                obj.flag = 1;
            end
            if obj.isCollided()
                toStop = true;
                obj.flag = 2;
            end
            if obj.isOutOfView()
                toStop = true;
                obj.flag = 3;
            end
            
            if nargout > 1
                flag = obj.flag;
            end
        end
        
        function out = isFallenDown(obj)
            % when the speed V is less than 10 m/s
            out = (obj.state(3) < 10);
        end
        
        function out = isCollided(obj)
            % when the altitude is less than -0.5 m
            out = (obj.state(2) < -0.5);
        end
        
        function out = isOutOfView(obj)
            % when the target has gone out of the field-of-view
            out = (abs(obj.lookAngle()) > obj.fovLimit);
        end
        
        function sigma = lookAngle(obj)
            % sigma = gamma - lambda
            assert(~isempty(obj.engKinematics),...
                "First assign the engagement kinematics")
            lam = obj.engKinematics.losAngle;
            sigma = obj.state(4) - lam;
        end
    end
end