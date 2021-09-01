classdef PlanarMissile3dof < PlanarManeuvVehicle3dof
    properties
        fovLimit = inf;
        accLimit = [...
            -inf, inf;...
            -inf, inf];
        engKinematics
        groundElevation = 0;
    end
    methods
        function obj = PlanarMissile3dof(initialState)
            obj = obj@PlanarManeuvVehicle3dof(initialState);
            obj.name = "planarMissile3dof";
        end
        
        function attachEngKinematics(obj, engKinematics)
            obj.engKinematics = engKinematics;
        end
        
        % override
        function out = forward(obj, a_M)
            a_M = CommonUtils.sat(a_M, obj.accLimit(:, 1), obj.accLimit(:, 2));
            forward@PlanarManeuvVehicle3dof(obj, a_M);
            if nargout > 1
                out = obj.output;
            end
        end
        
        % implement
        function varsToLog = log(obj, a_M)
            accSaturated = any(a_M <= obj.accLimit(:, 1) + 1e-8) ...
                || any(a_M >= obj.accLimit(:, 2) - 1e-8);
            varsToLog = {accSaturated};
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
            % when the altitude is less than the ground elevation
            out = (obj.state(2) < obj.groundElevation - 0.5);
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
        
        function report(obj)
            accSaturatedList = obj.history{4};
            if any(accSaturatedList)
                fprintf("[Missile] The acceleration command has been saturated. \n")
            end
        end
    end
end