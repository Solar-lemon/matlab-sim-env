classdef MySystem < SequentialSystem
    properties
        lqrGain
        linearSystem
    end
    methods
        function obj = MySystem()
            obj = obj@SequentialSystem();
            
            omega = 1;
            zeta  = 0.1;
            A = [0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            Q = diag([1, 1]);
            R = 1;
            obj.lqrGain = lqr(A, B, Q, R, []);
            obj.linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
            obj.attachDynSystems({obj.linearSystem});
        end
        
        % implement
        function forward(obj)
            % u_step = 1;
            u_lqr = -obj.lqrGain*obj.linearSystem.state;
            obj.linearSystem.forward(u_lqr);
        end
        
        function fig = plot(obj, fig)
            if nargin < 2
                fig = figure();
            end
            
            history = obj.linearSystem.history;
            [timeList, stateList, controlList] = history.get();
            
            figure(fig);
            subplot(2, 1, 1)
            hold on
            plot(timeList, stateList(1, :), 'DisplayName', 'x1')
            plot(timeList, stateList(2, :), 'DisplayName', 'x2')
            title('State')
            xlabel('Time')
            ylabel('State')
            grid on
            box on
            legend()
            
            subplot(2, 1, 2)
            hold on
            plot(timeList, controlList, 'DisplayName', 'u')
            title('Control input')
            xlabel('Time')
            ylabel('Control input')
            grid on
            box on
            legend()
        end
    end
    
    methods(Static)
        function test()
            clear
            clc
            close all
            
            fprintf('== Test for an example system class == \n')
            fprintf('Simulating the system... \n')
            
            mySystem = MySystem();
            saveHistory = true;
            dt = 0.01;
            finalTime = 10;
            
            tic
            mySystem.propagate(dt, finalTime, saveHistory);
            elapsedTime = toc;
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            
            mySystem.plot();
        end
    end
end