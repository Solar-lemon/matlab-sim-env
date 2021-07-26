classdef PlanarMissile3dof < PlanarManeuvVehicle3dof
    properties
        
    end
    methods
        function obj = PlanarMissile3dof(initialState)
            obj = obj@PlanarManeuvVehicle3dof(initialState);
            obj.name = 'planarMissile3dof';
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
    end
end