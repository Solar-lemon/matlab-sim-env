classdef QuadrotorDyn < MultiStateDynSystem
    properties
        % m: mass [kg], J: inertia [kg*m^2], g: gravity [m/s^2]
        m
        J
        g = 9.805
        e3 = [0; 0; 1];
    end
    methods
        function obj = QuadrotorDyn(initialState, m, J)
            obj = obj@MultiStateDynSystem(initialState);
            obj.m = m;
            obj.J = J;
        end
        
        % override
        function out = derivative(obj, p, v, R, omega, u)
            % p: position, 3x1 vector
            % v: velocity, 3x1 vector
            % R: rotation matrix, 3x3 matrix
            % omega: angular velocity, 3x1 vector
            % u = [f; tau]: control input, 4x1 vector
            f = u(1);
            tau = u(2:4);
            
            p_dot = v;
            v_dot = obj.g*obj.e3 - 1/obj.m*(f*R*obj.e3);
            R_dot = R*QuadrotorDyn.hat(omega);
            omega_dot = obj.J\(-cross(omega, obj.J*omega) + tau);
            
            out = {p_dot, v_dot, R_dot, omega_dot};
        end
        
        function figs = plot(obj, figs)
            if nargin < 2
                figs = cell(5, 1);
                for k = 1:5
                    figs{k} = figure();
                end
            end
            
            [timeList, posList, velList, ...
                rotationList, angVelList, controlList] = obj.history.get();
            
            figure(figs{1});
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
            sgtitle('Rotation matrix')
            hold on
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
            
            figure(figs{5});
            sgtitle('Control input')
            ylabelList = {'f [N]', 'tau_x [N*m]', 'tau_y [N*m]', 'tau_z [N*m]'};
            for k = 1:4
                subplot(4, 1, k)
                hold on
                plot(timeList, controlList(k, :))
                xlabel('Time')
                ylabel(ylabelList{k})
                grid on
                box on
            end
        end
    end
    
    methods(Static)
        function out = hat(v)
            out = [...
                0, -v(3), v(2);
                v(3), 0, -v(1);
                -v(2), v(1), 0];
        end
        
        function test()
            clc
            close all
            fprintf("== Test for QuadrotorDyn ==\n")

            m = 4.34;
            J = diag([0.0820, 0.0845, 0.1377]);
            
            pos = [0; 0; -1];
            vel = [1; 0; 0];
            R = eye(3);
            omega = [0; 0; 0.1];
            initialState = {pos, vel, R, omega};
            
            quadrotor = QuadrotorDyn(...
                initialState, m, J);
            
            u = [45; 0; 0; 0];
            dt = 0.01;
            finalTime = 10;
            
            tic
            Simulator(quadrotor).propagate(dt, finalTime, true, u);
            elapsedTime = toc;
            fprintf("Elapsed time: %.2f [s] \n", elapsedTime);
            
            quadrotor.plot();
        end
    end
end