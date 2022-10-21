classdef Simulator < handle
    properties
        simClock SimClock
        logTimer Timer
        model SimObject
        stateVars List
        verbose
    end
    methods
        function obj = Simulator(model, verbose, resetModel)
            arguments
                model SimObject
                verbose logical = true
                resetModel logical = true
            end
            obj.simClock = SimClock();
            obj.logTimer = Timer(inf);
            obj.logTimer.attachSimClock(obj.simClock);
            
            obj.model = model;
            obj.model.attachSimClock(obj.simClock);
            obj.model.attachLogTimer(obj.logTimer);
            if resetModel
                obj.model.reset();
            end

            obj.stateVars = model.collectStateVars();
            obj.verbose = verbose;
        end
        
        function reset(obj)
            obj.simClock.reset();
            obj.logTimer.turnOff();
            obj.model.reset();
        end
        
        function beginLogging(obj, logInterval)
            % logInterval must be greater than or equal to dt
            obj.logTimer.turnOn(logInterval);
        end
        
        function finishLogging(obj)
            obj.logTimer.turnOff();
        end
        
        function step(obj, dt, varargin)
            t_0 = obj.simClock.time;

            obj.simClock.majorTimeStep = true;
            obj.logTimer.forward();
            obj.model.forward(varargin{:});
            for i = 1:numel(obj.stateVars)
                obj.stateVars.get(i).rk4Update1(dt);
            end
            obj.simClock.majorTimeStep = false;

            obj.simClock.applyTime(t_0 + dt/2);
            obj.logTimer.forward();
            obj.model.forward(varargin{:});
            for i = 1:numel(obj.stateVars)
                obj.stateVars.get(i).rk4Update2(dt);
            end

            obj.model.forward(varargin{:});
            for i = 1:numel(obj.stateVars)
                obj.stateVars.get(i).rk4Update3(dt);
            end
            
            obj.simClock.applyTime(t_0 + dt - 10*obj.simClock.timeRes);
            obj.logTimer.forward();
            obj.model.forward(varargin{:});
            for i = 1:numel(obj.stateVars)
                obj.stateVars.get(i).rk4Update4(dt);
            end

            obj.simClock.applyTime(t_0 + dt);
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if saveHistory
                obj.beginLogging(dt);
            end

            obj.simClock.setTimeInterval(dt);
            obj.model.checkSimClock();
            obj.model.initialize();

            if obj.verbose
                fprintf("[simulator] Simulating... \n")
                if isempty(getCurrentTask()) % check if parallel computing is being performed.
                    tic
                end
            end

            % perform propagation
            iterNum = min(round(time/dt), intmax);
            for i = 1:iterNum
                toStop = obj.model.checkStopCondition(varargin{:});
                if toStop
                    break
                end
                obj.step(dt, varargin{:});
            end

            obj.logTimer.forward();
            obj.model.forward(varargin{:});

            if obj.verbose && isempty(getCurrentTask())
                elapsedTime = toc;
                fprintf("[simulator] Elapsed time: %.2f (s) \n", elapsedTime);
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