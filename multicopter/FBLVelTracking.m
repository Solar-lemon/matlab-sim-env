classdef FBLVelTracking < MultipleSystem
    properties
        quadrotor
        velControl
    end
    methods
        function obj = FBLVelTracking()
            obj = obj@MultipleSystem();
            
            % quadrotor model
            m = 0.5;
            J = diag([4.85, 4.85, 8.81]*1e-3);
            
            pos = [0; 0; 0];
            vel = [0; 0; 0];
            R_iv = eye(3);
            omega = [0; 0; 0];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % velocity controller
            obj.velControl = DiscreteFunction(...
                FBLVelControl(m, J), 1/100); % 100 Hz
            
            obj.attachDynSystems({obj.quadrotor});
            obj.attachDiscSystems({obj.velControl});
        end
        
        % implement
        function forward(obj, v_d)
            quadState = obj.quadrotor.stateValueList;
            v = quadState{2};
            R = quadState{3};
            omega = quadState{4};
            
            eta = Orientations.rotationToEulerAngles(R.');
            u = obj.velControl.forward(v, eta, omega, v_d);
            
            obj.quadrotor.forward(u);
        end
    end
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for FBLVelTracking == \n")
            
            v_d = [0.5; 0; 1];
            model = FBLVelTracking();
            Simulator(model).propagate(0.01, 10, true, v_d);
            
            model.quadrotor.plot();
        end
    end
end