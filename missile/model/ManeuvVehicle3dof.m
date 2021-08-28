classdef ManeuvVehicle3dof < DynSystem
    % 3 dof model for the maneuvering vehicle
    % state x = [p_n; p_e; p_d; V; gamma; chi]: 6x1 vector
    % control u = [a_x; a_y; a_z]: 3x1 vector
    % where (p_n, p_e, p_d) is the NED coordinate
    % (a_x, a_y, a_z) is the acceleration expressed in
    % the velocity frame
    properties
        
    end
    
    properties(Dependent)
        pos
        vel
        velVector
        RLocalToVelocity
        speed
        pathAngle
    end
    
    methods
        function obj = ManeuvVehicle3dof(initialState)
            obj = obj@DynSystem(initialState);
            
            function state = angleCorrectionFun(state)
                % gamma should be in [-pi, pi] rad
                % chi should be in [-pi, pi] rad
                state(5:6) = CommonUtils.wrapToPi(state(5:6));
            end
            obj.stateVar.attachCorrectionFun(@angleCorrectionFun);
            obj.name = 'maneuvVehicle3dof';
        end
        
        % override
        function out = derivative(obj, x, u)
            V = x(4);
            gamma = x(5);
            chi = x(6);
            
            a_x = u(1);
            a_y = u(2);
            a_z = u(3);
            
            c_gamma = cos(gamma);
            s_gamma = sin(gamma);
            
            p_n_dot = V*c_gamma*cos(chi);
            p_e_dot = V*c_gamma*sin(chi);
            p_d_dot = -V*s_gamma;
            V_dot = a_x;
            if abs(V) < 1e-4
                gamma_dot = 0;
            else
                gamma_dot = -a_z/V;
            end
            if abs(V*c_gamma) < 1e-4
                chi_dot = 0;
            else
                chi_dot = a_y/(V*c_gamma);
            end
            
            out = [p_n_dot; p_e_dot; p_d_dot; V_dot; gamma_dot; chi_dot];
        end
        
        function out = get.pos(obj)
            out = obj.state(1:3);
        end
        
        function out = get.vel(obj)
            state = obj.state;
            V = state(4);
            gamma = state(5);
            chi = state(6);
            
            out = [...
                V*cos(gamma)*cos(chi);
                V*cos(gamma)*sin(chi);
                -V*sin(gamma)];
        end
        
        function out = get.velVector(obj)
            state = obj.state;
            gamma = state(5);
            chi = state(6);
            
            out = [...
                cos(gamma)*cos(chi);
                cos(gamma)*sin(chi);
                -sin(gamma)];
        end
        
        function R_VL = get.RLocalToVelocity(obj)
            state = obj.state;
            gamma = state(5);
            chi = state(6);
            
            R_VL = Orientations.eulerAnglesToRotation([chi; gamma; 0]);
        end
        
        function out = get.speed(obj)
            % obj.speed = V
            out = obj.state(4);
        end
        
        function out = get.pathAngle(obj)
            % obj.pathAngle = [gamma; chi]
            out = obj.state(5:6);
        end
        
        function out = gravAccel(obj)
            gamma = obj.state(5);
            
            g_x = -FlatEarthEnv.gravAccel*sin(gamma);
            g_y = 0;
            g_z = FlatEarthEnv.gravAccel*cos(gamma);
            
            out = [g_x; g_y; g_z];
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
            posList = [stateList(1:2, :); -stateList(3, :)]/1E3;
            velList = stateList(4, :);
            angleList = rad2deg(stateList(5:6, :));
            
            figure(figs{1})
            sgtitle('State')
            
            subplot(4, 1, 1)
            labelList = {'p_n', 'p_n', 'h'};
            hold on
            for k = 1:3
                plot(timeList, posList(k, :), 'DisplayName', labelList{k})
            end
            xlabel('Time [s]')
            ylabel('Position [km]')
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
            labelList = {'gamma', 'chi'};
            hold on
            for k = 1:2
                plot(timeList, angleList(k, :), 'DisplayName', labelList{k});
            end
            xlabel('Time [s]')
            ylabel('Flight path angle [deg]')
            grid on
            box on
            legend()
            
            subplot(4, 1, 4)
            labelList = {'a_x', 'a_y', 'a_z'};
            hold on
            for k = 1:3
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
            posList = stateList(1:3, :);
            
            figure(fig)
            hold on
            plot3(posList(2, :), posList(1, :), -posList(3, :) ,'-o',...
                'MarkerIndices', [1, size(posList, 2)],...
                'DisplayName', obj.name)
            xlabel('E [m]')
            ylabel('N [m]')
            zlabel('h [m]')
            view(45, 30)
            grid on
            box on
            daspect([1 1 1])
        end
    end
end