classdef StationaryVehicle3dof < BaseFunction
    properties
        pos
        vel = zeros(3, 1);
        speed = 0;
    end
    methods
        function obj = StationaryVehicle3dof(pos)
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
            xlabel('E [m]')
            ylabel('N [m]')
            zlabel('h [m]')
            view(45, 30)
            grid on
            box on
            scatter3(obj.pos(2), obj.pos(1), -obj.pos(3));
        end
    end
end