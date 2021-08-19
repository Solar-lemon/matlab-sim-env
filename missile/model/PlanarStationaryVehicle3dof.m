classdef PlanarStationaryVehicle3dof < BaseFunction
    properties
        pos
        vel = zeros(2, 1);
    end
    
    methods
        function obj = PlanarStationaryVehicle3dof(pos)
            obj.pos = pos;
        end
        
        function forward(obj)
            % Do nothing
        end
        
        function fig = plotPath(obj, fig)
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