classdef ExampleSystem < MultipleSystem
    properties
        lqrGain
        linearSystem
        feedbackControl
    end
    methods
        function obj = ExampleSystem()
            obj = obj@MultipleSystem();
            
            zeta  = 0.1;
            omega = 1;
            A = [0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            Q = diag([1, 1]);
            R = 1;
            K = lqr(A, B, Q, R, []);
            
            % derivative function for a DynSystem can be either defined
            % using a function_handle or a BaseFunction instance
            % obj.linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
            obj.lqrGain = K;
            obj.linearSystem = DynSystem([0; 1], LinearDynFun(A, B));
            obj.feedbackControl = DiscreteFunction(@(x) -K*x, 0.2);
            
            obj.attachDynSystems({obj.linearSystem});
            obj.attachDiscSystems({obj.feedbackControl});
        end
        
        % implement
        function forward(obj)
            % u_lqr = -obj.lqrGain*obj.linearSystem.state;
            u_lqr = obj.feedbackControl.forward(obj.linearSystem.state);
            obj.linearSystem.forward(u_lqr);
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for an example system class == \n')
            fprintf('Simulating the system... \n')
            
            system = ExampleSystem();
            simulator = Simulator(system);
            
            dt = 0.01;
            finalTime = 10;
            saveHistory = true;
            
            tic
            simulator.propagate(dt, finalTime, saveHistory);
            elapsedTime = toc;
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            
            system.linearSystem.plot();
        end
    end
end