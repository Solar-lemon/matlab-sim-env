classdef GeoPosTracking < MultipleSystem
    properties
        quadrotor
        posControl
        attControl
    end
    methods
        function obj = GeoPosTracking()
            obj = obj@MultipleSystem();
            
            % quadrotor model
            m = 4.34;
            J = diag([0.0820, 0.0845, 0.1377]);
            
            pos = [0; 0; 0];
            vel = [0; 0; 0];
            R_iv = eye(3);
            omega = [0; 0; 0];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % position controller
            k_x = 16;
            k_v = 5.6;
            obj.posControl = DiscreteFunction(...
                GeoPosTrackingControl(m, k_x, k_v), 1/100); % 100 [Hz]
            
            % attitude controller
            k_R = 8.81;
            k_omega = 2.54;
            obj.attControl = DiscreteFunction(...
                GeoAttTrackingControl(J, k_R, k_omega), 1/100); % 100 [Hz]
            
            obj.attachDynSystems({obj.quadrotor});
            obj.attachDiscSystems({obj.posControl, obj.attControl});
        end
        
        % implement
        function forward(obj, var_x_d, var_psi_d)
            % var_x_d: desired position, DerivVariable of order 3
            % var_psi_d: desired heading, DerivVariable of order 1
            [p, v, R, omega] = obj.quadrotor.stateValueList{:};
            out = obj.posControl.forward(...
                p, v, R, var_x_d, var_psi_d);
            [f, var_R_d] = out{:};
            tau = obj.attControl.forward(R, omega, var_R_d);
            
            obj.quadrotor.forward([f; tau]);
            
            x_d = var_x_d.deriv(0);
            psi_d = var_psi_d.deriv(0);
            
            obj.logger.forward(x_d, psi_d);
            obj.logger.forwardVarNames('x_d', 'psi_d');
        end
        
        function fig = plot(obj)
            quadPos = obj.quadrotor.history{2};
            [trajTime, trajPos, trajHead] = obj.history{1:3};
            
            quadFigs = obj.quadrotor.plot();
            figure(quadFigs{1});
            for k = 1:3
                subplot(3, 1, k);
                hold on
                plot(trajTime, trajPos(k, :), '--', 'DisplayName', "Desired pos.")
                legend()
            end
            
            figure(quadFigs{5});
            subplot(3, 1, 3);
            hold on
            plot(trajTime, rad2deg(trajHead), '--', 'DisplayName', "Desired head.")
            legend()
            
            set(0,'DefaultFigureWindowStyle','docked')
            fig = figure();
            fig.Name = "Trajectory";
            hold on
            plot3(quadPos(1, :), quadPos(2, :), quadPos(3, :), '-o',...
                'MarkerIndices', [1, size(quadPos, 2)],...
                'DisplayName', "Actual traj.")
            plot3(trajPos(1, :), trajPos(2, :), trajPos(3, :), '--o',...
                'MarkerIndices', [1, size(trajPos, 2)],...
                'DisplayName', "Desired traj.")
            title("Trajectory")
            xlabel('x')
            ylabel('y')
            zlabel('z')
            view([-45, 30])
            daspect([1 1 1])
            grid on
            legend('Location', 'Northoutside')
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end