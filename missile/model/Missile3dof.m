classdef Missile3dof < ManeuvVehicle3dof
    properties
       fovLimit = inf;
       accLimit = [...
           -inf, inf;
           -inf, inf;
           -inf, inf];
       engKinematics
    end
    methods
        function obj = Missile3dof(initialState)
            obj = obj@ManeuvVehicle3dof(initialState);
            obj.name = "missile3dof";
        end
        
        function attachEngKinematics(obj, engKinematics)
            obj.engKinematics = engKinematics;
        end
        
        % override
        function out = forward(obj, a_M)
            a_M = CommonUtils.sat(a_M, obj.accLimit(:, 1), obj.accLimit(:, 2));
            forward@ManeuvVehicle3dof(obj, a_M);
            
            accSaturated = any(a_M <= obj.accLimit(:, 1) + 1e-8) ...
                || any(a_M >= obj.accLimit(:, 2) - 1e-8);
            obj.logger.forward('accSaturated', accSaturated);
            if nargout > 1
                out = obj.output;
            end
        end
        
        % implement
        function [toStop, flag] = checkStopCondition(obj)
            toStop = false;
            if obj.isFallenDown
                toStop = true;
                obj.flag = 1;
            end
            if obj.isCollided
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
            state = obj.state;
            out = (state(4) < 10);
        end
        
        function out = isCollided(obj)
            % when the height is less than -0.5 m
            state = obj.state;
            out = (state(3) > 0.5);
        end
        
        function out = isOutOfView(obj)
            % when the target has gone out of the field-of-view
            out = (abs(obj.lookAngle()) > obj.fovLimit);
        end
        
        function sigma = lookAngle(obj)
            assert(~isempty(obj.engKinematics),...
                "First assign the engagement kinematics")
            losVector = obj.engKinematics.losVector;
            sigma = acos(obj.velVector.'*losVector);
        end
        
        function report(obj)
            accSaturatedList = obj.history('accSaturated');
            if any(accSaturatedList)
                fprintf("[Missile] The acceleration command has been saturated. \n")
            end
        end
    end
end