classdef Missile3dof < ManeuvVehicle3dof
    properties
       
    end
    methods
        function obj = Missile3dof(initialState)
            obj = obj@ManeuvVehicle3dof(initialState);
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
            state = obj.state;
            out = (state(4) < 10);
        end
        
        function out = isCollided(obj)
            % when the height is less than -0.5 m
            state = obj.state;
            out = (state(3) > 0.5);
        end
            
    end
end