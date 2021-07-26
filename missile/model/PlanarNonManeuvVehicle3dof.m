classdef PlanarNonManeuvVehicle3dof < PlanarManeuvVehicle3dof
    % 3 dof model for the maneuvering vehicle in the two-dim plane.
    % state x = [p_x; p_y; V; gamma]: 4x1 vector
    properties
        
    end
    methods
        function obj = PlanarNonManeuvVehicle3dof(initialState)
            obj = obj@PlanarManeuvVehicle3dof(initialState);
        end
        
        % override
        function out = derivative(obj, x)
            out = derivative@PlanarManeuvVehicle3dof(obj, x, zeros(2, 1));
        end
    end
end