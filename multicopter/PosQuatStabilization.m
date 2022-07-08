classdef PosQuatStabilization < MultipleSystem
    properties
        quadrotor
        attControl
        posControl
    end
    methods
        function obj = PosQuatStabilization()
            obj = obj@MultipleSystem();
            
            % quadrotor model
            m = 1.3;
            J = diag([0.0119, 0.0119, 0.0219]);
            
            pos = [1; 2; 0];
            vel = [0; 0; 0];
            R_vi = eye(3);
            R_iv = R_vi.';
            omega = [0; 0; 0];
            initialState = {pos, vel, R_iv, omega};
            
            obj.quadrotor = QuadrotorDyn(initialState, m, J);
            
            % attitude controller
            Q_att = diag([1, 1, 1, 0.1, 0.1, 0.1].^2);
            R_att = 0.0001*eye(3);
            K_att = AttQuatControl.gain(Q_att, R_att);
            obj.attControl = AttQuatControl(J, K_att);
            
            % position controller
            Q_pos = diag([1, 1, 1, 0.1, 0.1, 0.1].^2);
            R_pos = 1*eye(3);
            K_pos = PosQuatControl.gain(Q_pos, R_pos);
            obj.posControl = PosQuatControl(m, K_pos);
            
            obj.attachSimObjects({obj.quadrotor});
        end
        
        % implement
        function forward(obj)
            p_d = [0; 0; 1];
            v_d = [0; 0; 0];
            
            quadState = obj.quadrotor.state;
            p = quadState{1};
            v = quadState{2};
            R_iv = quadState{3};
            omega = quadState{4}; 
            q = Orientations.rotationToQuat(R_iv.');
            
            [f, q_d, omega_d] = obj.posControl.forward(p, v, p_d, v_d);
            tau = obj.attControl.forward(q, omega, q_d, omega_d);
            
            obj.quadrotor.forward([f; tau]);
        end
    end
end