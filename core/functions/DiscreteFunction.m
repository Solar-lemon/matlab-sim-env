classdef DiscreteFunction < BaseFunction
    properties
        useBaseFunction
        fun
        time = 0
        timer
        output
    end
    methods
        function obj = DiscreteFunction(fun, eventTimeInterval)
            % fun: function_handle or BaseFunction
            obj.useBaseFunction = isa(fun, 'BaseFunction');
            obj.fun = fun;
            obj.timer = Timer(eventTimeInterval);
            obj.timer.turnOn(obj.time, true);
        end
        
        function reset(obj)
            obj.time = 0;
            obj.timer.turnOn(obj.time, true);
        end
        
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
        end
        
        % implement
        function out = forward(obj, varargin)
            obj.timer.forward(obj.time);
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
            feedbackFun = @(x) -K*x;
            feedbackControl = DiscreteFunction(feedbackFun, 0.2);
            
            dt = 0.01;
            finalTime = 10;
            iterNum = floor(finalTime/dt);
            
            time = 0;
            simulator = Simulator(system);
            simulator.startLogging(dt);
            for i = 1:iterNum
                feedbackControl.applyTime(time);
                
                x = system.state;
                u = feedbackControl.forward(x);
                
                simulator.step(dt, u);
                time = time + dt;
            end
            simulator.finishLogging();
            system.plot();
        end
    end
end