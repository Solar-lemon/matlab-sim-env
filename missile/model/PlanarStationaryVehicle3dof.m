classdef PlanarStationaryVehicle3dof < handle
    properties
        pos
    end
    properties(Dependent)
        vel
    end
    
    methods
        function obj = PlanarStationaryVehicle3dof(pos)
            obj.pos = pos;
        end
    end
    % set and get methods
    methods
        function out = get.vel(obj)
            out = zeros(2, 1);
        end
        
        function fig = plotPos(obj, fig)
            if nargin < 2
                fig = figure();
            end
            figure(fig);
            hold on
            xlabel('p_x [m]')
            ylabel('p_y [m]')
            grid on
            box on
            scatter(obj.pos(1), obj.pos(2));
        end
    end
end