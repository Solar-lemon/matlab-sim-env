classdef DiscreteFunction < BaseFunction
    properties
        fun
        useBaseFunction
        eventTimeInterval
        timer
        output
    end
    methods
        function obj = DiscreteFunction(fun, eventTimeInterval)
            % fun: function_handle or BaseFunction
            obj.fun = fun;
            obj.useBaseFunction = isa(fun, 'BaseFunction');
            obj.eventTimeInterval = eventTimeInterval;
        end
        
        function attachSimClock(obj, simClock)
            obj.timer = Timer(obj.eventTimeInterval);
            obj.timer.attachSimClock(simClock);
            obj.timer.turnOn();
        end
        
        function reset(obj)
            obj.timer.turnOn();
        end
        
        % implement
        function out = forward(obj, varargin)
            assert(~isempty(obj.timer),...
                "[DiscreteFunction] Attach a clock first.\n")
            obj.timer.forward();
            if obj.timer.checkEvent()
                if obj.useBaseFunction
                    obj.output = obj.fun.forward(varargin{:});
                else
                    obj.output = obj.fun(varargin{:});
                end
            end
            out = obj.output;
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for DiscreteFunction ==\n')
            
            A = [0, 1;
                -1, -0.2];
            B = [0; 1];
            system = DynSystem([0; 1], LinearDynFun(A, B));
            
            K = [0.4142, 1.1669];
            feedbackFun = @(x, r) -K*x;
            feedbackControl = DiscreteFunction(feedbackFun, 0.2);
            
            model = FeedbackControl(system, feedbackControl);
            
            dt = 0.01;
            finalTime = 10;
            
            simulator = Simulator(model);
            simulator.propagate(dt, finalTime, true);
            system.plot();
        end
    end
end