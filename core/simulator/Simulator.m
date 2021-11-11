classdef Simulator < handle
    properties
        simClock
        logTimer
        model
    end
    methods
        function obj = Simulator(model)
            % model: an object of BaseSystem class or its subclass
            if nargin < 1
                model = [];
            end
            obj.simClock = SimClock();
            obj.logTimer = Timer(inf);
            obj.logTimer.attachSimClock(obj.simClock);
            
            obj.model = model;
            obj.model.attachSimClock(obj.simClock);
            obj.model.attachLogTimer(obj.logTimer);
        end
        
        function reset(obj)
            obj.simClock.reset();
            obj.logTimer.turnOff();
            obj.model.reset();
        end
        
        function beginLogging(obj, logInterval)
            obj.logTimer.turnOn(logInterval);
        end
        
        function finishLogging(obj)
            obj.logTimer.turnOff();
        end
        
        function step(obj, dt, varargin)
            obj.model.step(dt, varargin{:});
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = true;
            end
            
            try
                measureElapsedTime = isempty(getCurrentTask());
            catch
                measureElapsedTime = true;
            end
            
            if saveHistory
                obj.beginLogging(dt);
            end
            if measureElapsedTime
                fprintf("[Simulator] Simulating... \n")
                tic
            end
            obj.model.propagate(dt, time, varargin{:});
            if measureElapsedTime
                elapsedTime = toc;
                fprintf("[Simulator] Elapsed time: %.2f [s] \n", elapsedTime);
            end
            
            obj.finishLogging();
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for Simulator class == \n')
            fprintf('Test for propagate method \n')
            
            A = [0, 1; -1, -1];
            B = [0; 1];
            derivFun = @(x, u) A*x + B*u;
            
            model = DynSystem([0; 1], derivFun);
            simulator = Simulator(model);
            
            dt = 0.01;
            finalTime = 5;
            saveHistory = true;
            u_step = 1;
            
            simulator.propagate(dt, finalTime, saveHistory, u_step);
            simulator.propagate(dt, finalTime, saveHistory, u_step);
            
            model.plot();
            
            fprintf('Test for step method \n')
            simulator.reset();
            simulator.beginLogging(dt);
            for i = 1:1000
                simulator.step(dt, u_step);
            end
            simulator.finishLogging();
            model.plot();
        end
    end
end