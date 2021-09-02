classdef ExampleDyn < MultiStateDynSystem
    properties
        % m: mass [kg], J: inertia [kg*m^2]
        m
        J
        e3 = [0; 0; 1];
        gravAccel
        rotationDyn
    end
    methods
        function obj = ExampleDyn(initialState, m, J)
            % initialState = {p, v, R, omega};
            obj = obj@MultiStateDynSystem(initialState(1:2));
            obj.m = m;
            obj.J = J;
            obj.gravAccel = FlatEarthEnv.gravAccel*obj.e3;
            obj.rotationDyn = ExampleRotationDyn(initialState(3:4), J);
            
            obj.attachDynSystems({obj.rotationDyn});
        end
        
        % implement
        function out = derivative(obj, p, v, R, omega, u)
            % p: position, 3x1 vector
            % v: velocity, 3x1 vector
            % R: rotation matrix, 3x3 matrix
            % omega: angular velocity, 3x1 vector
            % u = [f; tau]: control input, 4x1 vector
            f = u(1);
            tau = u(2:4);
            
            p_dot = v;
            v_dot = obj.gravAccel - 1/obj.m*(f*R*obj.e3);
            Romega_dot = obj.rotationDyn.derivative(R, omega, tau);
            
            out = [{p_dot, v_dot}, Romega_dot];
        end
        
        % override
        function forward(obj, u)
            forward@MultiStateDynSystem(obj, u);
            obj.rotationDyn.forward(u(2:4));
        end
        
        % implement
        function figs = plot(obj, figs)
            set(0,'DefaultFigureWindowStyle','docked')
            if nargin < 2
                figs = cell(4, 1);
                for k = 1:4
                    figs{k} = figure();
                end
            end
            
            [timeList, posList, velList, ...
                rotationList, angVelList] = obj.history{1:5};
            
            figure(figs{1});
            figs{1}.Name = 'Position';
            sgtitle('Position')
            ylabelList = {'x [m]', 'y [m]', 'z [m]'};
            for k = 1:3
                subplot(3, 1, k)
                hold on
                plot(timeList, posList(k, :))
                xlabel('Time')
                ylabel(ylabelList{k})
                grid on
                box on
            end
            
            figure(figs{2});
            figs{2}.Name = 'Velocity';
            sgtitle('Velocity')
            ylabelList = {'v_x [m/s]', 'v_y [m/s]', 'v_z [m/s]'};
            for k = 1:3
                subplot(3, 1, k)
                hold on
                plot(timeList, velList(k, :))
                xlabel('Time')
                ylabel(ylabelList{k})
                grid on
                box on
            end
            
            figure(figs{3});
            figs{3}.Name = 'Rotation matrix';
            sgtitle('Rotation matrix')
            for j = 1:3
                subplot(3, 1, j)
                hold on
                for i = 1:3
                    plot(timeList, squeeze(rotationList(i, j, :)),...
                        'DisplayName', sprintf('r_%d_%d', i, j))
                end
                xlabel('Time [s]')
                ylabel('Value')
                ylim([-1.2, 1.2])
                grid on
                box on
                legend()
            end
            
            figure(figs{4});
            figs{4}.Name = 'Angular velocity';
            sgtitle('Angular velocity')
            ylabelList = {'omega_x [deg/s]', 'omega_y [deg/s]', 'omega_z [deg/s]'};
            for k = 1:3
                subplot(3, 1, k)
                hold on
                plot(timeList, rad2deg(angVelList(k, :)))
                xlabel('Time')
                ylabel(ylabelList{k})
                grid on
                box on
            end
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end