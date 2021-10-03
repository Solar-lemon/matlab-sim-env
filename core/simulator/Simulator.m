classdef Simulator < handle
    properties
        simClock
        model
        inValues
    end
    methods
        function obj = Simulator(model)
            % model: an object of BaseSystem class or its subclass
            if nargin < 1
                model = [];
            end
            obj.simClock = Clock();
            obj.model = model;
            obj.model.attachSimClock(obj.simClock);
        end
        
        function reset(obj)
            obj.simClock.reset();
            obj.model.reset();
        end
        
        function startLogging(obj, interval, timeResolution)
            if nargin < 3
                timeResolution = 1e-6;
            end
            obj.simClock.applyTimeResolution(timeResolution);
            obj.model.startLogging(interval);
        end
        
        function finishLogging(obj)
            obj.model.forwardWrapper(obj.inValues);
            obj.model.finishLogging();
        end
        
        function step(obj, dt, varargin)
            toStop = obj.model.checkStopCondition();
            if toStop
                return
            end
            
            obj.model.step(dt, varargin);
            obj.inValues = varargin;
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = false;
            end
            measureElapsedTime = isempty(getCurrentTask());
            iterNum = min(round(time/dt), intmax('int32'));
            
            for i = 1:numel(varargin)
                if isa(varargin{i}, 'DiscreteFunction')
                    varargin{i}.attachSimClock(obj.simClock);
                end
            end
            
            if saveHistory
                obj.startLogging(dt, 0.0001*dt);
            end
            if measureElapsedTime
                fprintf("[Simulator] Simulating... \n")
                tic
            end
            for i = 1:iterNum
                toStop = obj.model.checkStopCondition();
                if toStop
                    break
                end
                obj.model.step(dt, varargin);
            end
            if measureElapsedTime
                elapsedTime = toc;
                fprintf("[Simulator] Elapsed time: %.2f [s] \n", elapsedTime);
            end
            
            obj.inValues = varargin;
            obj.finishLogging();
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for Simulator class == \n')
            fprintf('Test for propagate method \n')
            fprintf('Simulating the system... \n')
            
            model = ExampleSystem(); % Refer to ExampleSystem class
            initialState = model.state;
            simulator = Simulator(model);
            
            dt = 0.01;
            finalTime = 5;
            saveHistory = true;
            
            simulator.propagate(dt, finalTime, saveHistory);
            simulator.propagate(dt, finalTime, saveHistory);
            
            fprintf('Initial state of the system: \n')
            disp(initialState)
            fprintf('State of the system after 10[s]: \n\n')
            disp(model.state)
            
            model.linearSystem.plot();
            
            fprintf('Test for step method \n')
            simulator.reset();
            simulator.startLogging(0.01, 1e-6);
            for i = 1:1000
                simulator.step(0.01);
            end
            simulator.finishLogging();
            model.linearSystem.plot();
        end
    end
end