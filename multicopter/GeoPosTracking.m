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
            k_x = 16*m;
            k_v = 5.6*m;
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
            [f, R_d, omega_d] = out{:};
            tau = obj.attControl.forward(R, omega, R_d, omega_d);
            
            obj.quadrotor.forward([f; tau]);
        end
    end
end