classdef PlanarManeuvVehicle3dof < DynSystem
    % 3 dof model for the maneuvering vehicle in the two-dim plane.
    % state x = [p_x; p_y; V; gamma]: 4x1 vector
    % control u = [a_x; a_y]; 2x1 vector
    % where (p_x, p_y) is the position, (a_x, a_y) is the acceleration
    % expressed in the velocity frame
    properties
        
    end
    properties(Dependent)
        pos
        vel
        speed
        pathAngle
    end
    
    methods
        function obj = PlanarManeuvVehicle3dof(initialState)
            obj = obj@DynSystem(initialState);
            
            function state = angleCorrectionFun(state)
                % gamma should be in [-pi, pi] rad
                state(4) = CommonUtils.wrapToPi(state(4));
            end
            obj.stateVar.attachCorrectionFun(@angleCorrectionFun);
            obj.name = 'planarManeuvVehicle3dof';
        end
        
        % implement
        function out = derivative(obj, x, u)
            V = x(3);
            gamma = x(4);
            
            a_x = u(1);
            a_y = u(2);
            
            p_x_dot = V*cos(gamma);
            p_y_dot = V*sin(gamma);
            V_dot = a_x;
            if abs(V) < 1e-4
                gamma_dot = 0;
            else
                gamma_dot = a_y/V;
            end
            
            out = [p_x_dot; p_y_dot; V_dot; gamma_dot];
        end
        
        function figs = plot(obj, figs)
            if nargin < 2
                figs = cell(1, 1);
                for k = 1:numel(figs)
                    figs{k} = figure();
                end
            end
            
            [timeList, stateList, accelList] = obj.history{:};
            % posList: km, velList: m/s, angleList: deg, accelList: m/s^2
            posList = stateList(1:2, :);
            velList = stateList(3, :);
            angleList = rad2deg(stateList(4, :));
            
            figure(figs{1})
            sgtitle('State and control')
            
            subplot(4, 1, 1)
            labelList = {'p_x', 'p_y'};
            hold on
            for k = 1:2
                plot(timeList, posList(k, :), 'DisplayName', labelList{k})
            end
            xlabel('Time [s]')
            ylabel('Position [m]')
            grid on
            box on
            legend()
            
            subplot(4, 1, 2)
            hold on
            plot(timeList, velList, 'DisplayName', 'V')
            xlabel('Time [s]')
            ylabel('Speed [m/s]')
            grid on
            box on
            legend()
            
            subplot(4, 1, 3)
            hold on
            plot(timeList, angleList, 'DisplayName', 'gamma')
            xlabel('Time [s]')
            ylabel('Flight path angle [deg]')
            grid on
            box on
            legend()
            
            subplot(4, 1, 4)
            labelList = {'a_x', 'a_y'};
            hold on
            for k = 1:2
                plot(timeList, accelList(k, :), 'DisplayName', labelList{k});
            end
            xlabel('Time [s]')
            ylabel('Acceleration [m/s^2]')
            grid on
            box on
            legend()
        end
        
        function fig = plotPath(obj, fig)
            if nargin < 2
                fig = figure();
            end
            stateList = obj.history{2};
            posList = stateList(1:2, :);
            
            figure(fig)
            hold on
            plot(posList(1, :), posList(2, :), '-o',...
                'MarkerIndices', [1, size(posList, 2)],...
                'DisplayName', obj.name)
            xlabel('p_x [m]')
            ylabel('p_y [m]')
            grid on
            box on
            daspect([1 1 1])
        end
    end
    % set and get methods
    methods
        function out = get.pos(obj)
            out = obj.state(1:2);
        end
        
        function out = get.vel(obj)
            state = obj.state;
            V = state(3);
            gamma = state(4);
            
            out = [...
                V*cos(gamma);
                V*sin(gamma)];
        end
        
        function out = get.speed(obj)
            % obj.speed = V;
            out = obj.state(3);
        end
        
        function out = get.pathAngle(obj)
            % obj.pathAngle = gamma;
            out = obj.state(4);
        end
    end
end
        
    