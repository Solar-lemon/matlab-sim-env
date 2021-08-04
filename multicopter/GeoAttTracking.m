classdef GeoAttTracking < MultipleSystem
    properties(Constant)
        STAB_MODE = 0
        TRACK_MODE = 1
    end
    properties
        quadrotor
        attControl
        testMode
    end
    methods
        function obj = GeoAttTracking(testMode)
            if nargin < 1
                testMode = GeoAttTracking.STAB_MODE;
            end
            obj = obj@MultipleSystem();
            obj.testMode = testMode;
            
            % quadrotor model
            m = 4.34;
            J = diag([0.0820, 0.0845, 0.1377]);
            
            pos = [0; 0; 0];
            vel = [0; 0; 0];
            switch testMode
                case GeoAttTracking.STAB_MODE
                    R_iv = [...
                        1, 0, 0;
                        0, -0.9995, -0.0314;
                        0, 0.0314, -0.9995];
                case GeoAttTracking.TRACK_MODE
                    R_iv = eye(3);
            end
            omega = [0; 0; 0];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % attitude controller
            k_R = 8.81;
            k_omega = 2.54;
            obj.attControl = DiscreteFunction(...
                GeoAttTrackingControl(J, k_R, k_omega), 1/100); % 100 [Hz]
            
            obj.attachDynSystems({obj.quadrotor});
            obj.attachDiscSystems({obj.attControl});
        end
        
        % implement
        function forward(obj, var_R_d)
            switch obj.testMode
                case GeoAttTracking.STAB_MODE
                    % var_R_d are constant.
                    var_R_d = DerivVariable(eye(3));
                case GeoAttTracking.TRACK_MODE
                    % var_R_d is an object of DerivVariable.
            end
            
            quadState = obj.quadrotor.stateValueList;
            R = quadState{3};
            omega = quadState{4};
            
            Psi = GeoAttTrackingControl.attitudeError(R, var_R_d.deriv(0));
            f = obj.quadrotor.m*FlatEarthEnv.gravAccel;
            tau = obj.attControl.forward(R, omega, var_R_d);
            
            obj.quadrotor.forward([f; tau]);
            if obj.logger.toLog()
                obj.logger.forward(Psi);
                obj.logger.forwardVarNames('attError');
            end
        end
        
        function fig = plot(obj, fig)
            set(0,'DefaultFigureWindowStyle','docked')
            if nargin < 2
                fig = figure();
            end
            
            [timeList, attErrorList] = obj.history{:};
            
            figure(fig);
            fig.Name = 'Attitude Error Function';
            hold on
            plot(timeList, attErrorList);
            title('Attitude Error Function')
            xlabel('Time [s]')
            ylabel('Psi')
            ylim([-0.5, 2])
            grid on
            box on
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end