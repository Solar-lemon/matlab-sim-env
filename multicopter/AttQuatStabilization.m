classdef AttQuatStabilization < MultipleSystem
    properties
        quadrotor
        attControl
    end
    methods
        function obj = AttQuatStabilization()
            obj = obj@MultipleSystem();
            
            % quadrotor model
            m = 1.3;
            J = diag([0.0119, 0.0119, 0.0219]);
            
            pos = [1; 2; 0];
            vel = [0; 0; 0];
            R_vi = Orientations.eulerAnglesToRotation(...
                deg2rad([10; 10; 20]));
            R_iv = R_vi.';
            omega = [0; 0; 1];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % attitude controller
            Q = diag([1, 1, 1, 0.1, 0.1, 0.1].^2);
            R = 0.0001*eye(3);
            K = AttQuatControl.gain(Q, R);
            obj.attControl = AttQuatControl(J, K);
            
            obj.attachDynSystems({obj.quadrotor});
        end
        
        % implement
        function forward(obj)
            q_d = [1; 0; 0; 0];
            omega_d = [0; 0; 0];
            
            quadState = obj.quadrotor.stateValueList;
            R_iv = quadState{3};
            omega = quadState{4};
            q = Orientations.rotationToQuat(R_iv.');
            
            f = obj.quadrotor.m*FlatEarthEnv.gravAccel;
            tau = obj.attControl.forward(q, omega, q_d, omega_d);
            
            obj.quadrotor.forward([f; tau]);
        end
    end
end