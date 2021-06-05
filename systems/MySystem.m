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
        
        function [fig, ax] = plot(obj, fig, ax)
            if nargin < 2
                fig = figure();
            end
            if nargin < 3
                ax = axes('Parent', fig);
            end
            
            history = obj.linearSystem.history;
            [timeList, stateList] = history.get();
            
            figure(fig);
            hold on
            plot(ax, timeList, stateList(1, :), 'DisplayName', 'x1')
            plot(ax, timeList, stateList(2, :), 'DisplayName', 'x2')
            xlabel('Time')
            ylabel('State')
            grid on
            box on
            legend()
        end
    end
end