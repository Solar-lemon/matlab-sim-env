classdef GeoAttTracking < MultipleSystem
    properties
        quadrotor
        attControl
    end
    methods
        function obj = GeoAttTracking()
            obj = obj@MultipleSystem();
            
            % quadrotor model
            m = 4.34;
            J = diag([0.0820, 0.0845, 0.1377]);
            
            pos = [0; 0; 0];
            vel = [0; 0; 0];
            R_iv = [...
                1, 0, 0;
                0, -0.9995, -0.0314;
                0, 0.0314, -0.9995];
            omega = [0; 0; 0];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % attitude controller
            k_R = 8.81;
            k_omega = 2.54;
            obj.attControl = GeoAttTrackingControl(J, k_R, k_omega);
            
            obj.attachDynSystems({obj.quadrotor});
        end
        
        % implement
        function forward(obj)
            R_d = eye(3);
            omega_d = zeros(3, 1);
            
            quadState = obj.quadrotor.stateValueList;
            R = quadState{3};
            omega = quadState{4};
            
            Psi = GeoAttTrackingControl.attitudeError(R, R_d);
            f = obj.quadrotor.m*obj.quadrotor.g;
            tau = obj.attControl.forward(R, omega, R_d, omega_d);
            
            obj.quadrotor.forward([f; tau]);
            if obj.logger.toLog()
                obj.logger.forward(Psi);
                obj.logger.forwardVarNames('attError');
            end
        end
        
        function fig = plot(obj, fig)
            if nargin < 2
                fig = figure();
            end
            
            [timeList, attErrorList] = obj.history{:};
            
            figure(fig);
            hold on
            plot(timeList, attErrorList);
            title('Attitude Error Function')
            xlabel('Time [s]')
            ylabel('Psi')
            ylim([-0.5, 2])
            grid on
            box on
        end
    end
end