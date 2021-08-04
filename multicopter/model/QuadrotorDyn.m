classdef QuadrotorDyn < MultiStateDynSystem
    properties
        % m: mass [kg], J: inertia [kg*m^2], gravAccel: gravity [m/s^2]
        m
        J
        e3 = [0; 0; 1];
        gravAccel
    end
    methods
        function obj = QuadrotorDyn(initialState, m, J)
            obj = obj@MultiStateDynSystem(initialState);
            obj.m = m;
            obj.J = J;
            obj.gravAccel = FlatEarthEnv.gravAccel*obj.e3;
            
            function R = rotationCorrectionFun(R)
                % rotation matrix should be orthogonal
                isOrthogonal = Orientations.checkOrthogonality(R);
                if ~isOrthogonal
                    R = Orientations.correctOrthogonality(R);
                end
            end
            obj.stateVarList{3}.attachCorrectionFun(@rotationCorrectionFun);
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
            v_dot = obj.gravAccel - 1/obj.m*(f*R*obj.e3);
            R_dot = R*QuadrotorDyn.hat(omega);
            omega_dot = obj.J\(-cross(omega, obj.J*omega) + tau);
            
            out = {p_dot, v_dot, R_dot, omega_dot};
        end
        
        function figs = plot(obj, figs)
            set(0,'DefaultFigureWindowStyle','docked')
            if nargin < 2
                figs = cell(7, 1);
                for k = 1:7
                    figs{k} = figure();
                end
            end
            
            [timeList, posList, velList, ...
                rotationList, angVelList, controlList] = obj.history{:};
            dataNum = size(rotationList, 3);
            
            quatList = nan(4, dataNum);
            eulerAngleList = nan(3, dataNum);
            for i = 1:dataNum
                quatList(:, i) = ...
                    Orientations.rotationToQuat(rotationList(:, :, i).');
                eulerAngleList(:, i) = ...
                    Orientations.rotationToEulerAngles(rotationList(:, :, i).');
            end
            
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
            figs{4}.Name = 'Quaternion';
            sgtitle('Quaternion')
            hold on
            for k = 1:4
                plot(timeList, quatList(k, :),...
                    'DisplayName', sprintf('q_%d', k))
            end
            xlabel('Time [s]')
            ylabel('Value')
            ylim([-1.2, 1.2])
            grid on
            box on
            legend()
            
            figure(figs{5});
            figs{5}.Name = 'Euler angles';
            sgtitle('Euler angles')
            ylabelList = {'phi [deg]', 'theta [deg]', 'psi [deg]'};
            for k = 1:3
                subplot(3, 1, k)
                hold on
                plot(timeList, rad2deg(eulerAngleList(k, :)))
                xlabel('Time [s]')
                ylabel(ylabelList{k})
                grid on
                box on
            end
            
            figure(figs{6});
            figs{6}.Name = 'Angular velocity';
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
            
            figure(figs{7});
            figs{7}.Name = 'Control input';
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
            set(0,'DefaultFigureWindowStyle','normal')
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