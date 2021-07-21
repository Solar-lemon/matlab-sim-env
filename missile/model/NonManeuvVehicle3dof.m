classdef NonManeuvVehicle3dof < ManeuvVehicle3dof
    % 3 dof model for the nonmaneuvering vehicle
    % state x = [p_n; p_e; p_d; V; gamma; chi]: 6x1 vector
    properties
        
    end
    methods
        function obj = NonManeuvVehicle3dof(initialState)
            obj = obj@ManeuvVehicle3dof(initialState);
        end
        
        % override
        function out = derivative(obj, x)
            out = derivative@ManeuvVehicle3dof(obj, x, zeros(3, 1));
        end
    end
end