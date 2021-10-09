classdef Logger < handle
    properties
        simClock
        timer
        data
        isInitialized = false
        name = "Logger"
    end
    methods
        function obj = Logger()
            obj.data = containers.Map();
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end
        
        function reset(obj)
            obj.timer = [];
            obj.data.remove(obj.data.keys());
            obj.isInitialized = false;
        end
        
        function turnOn(obj, logTimeInterval)
            assert(~isempty(obj.simClock), "[Logger] Attach a clock first.\n")
            obj.timer = Timer(logTimeInterval);
            obj.timer.attachSimClock(obj.simClock);
            obj.timer.turnOn();
        end
        
        function turnOff(obj)
            obj.timer.turnOff();
        end
        
        function out = isempty(obj)
            out = obj.data.isempty();
        end
        
        function out = toLog(obj)
            obj.timer.forward();
            out = ~isempty(obj.timer) && obj.timer.checkEvent();
        end
        
        function out = numel(obj)
            if obj.data.isempty()
                out = 0;
                return
            end
            keys = obj.data.keys();
            out = obj.data(keys{1}).numel();
        end
        
        function forward(obj, keySet, valueSet)
            obj.timer.forward();
            if ~isempty(obj.timer) && obj.timer.checkEvent()
                if ~isa(keySet, 'cell')
                    keySet = {keySet};
                end
                if ~isa(valueSet, 'cell')
                    valueSet = {valueSet};
                end
                
                if ~obj.isInitialized
                    if obj.data.isKey(keySet{1})
                        obj.isInitialized = true;
                    else
                        for i = 1:numel(keySet)
                            obj.data(keySet{i}) = MatrixList();
                        end
                    end
                end
                for i = 1:numel(keySet)
                    matrixList = obj.data(keySet{i});
                    matrixList.append(valueSet{i});
                end
            end
        end
        
        function loggedData = get(obj, keySet)
            if nargin < 2
                keySet = obj.data.keys();
            end
            loggedData = cell(size(keySet));
            for i = 1:numel(loggedData)
                loggedData{i} = obj.data(keySet{i}).get();
            end
        end
    end
    methods(Static)
        function test()
            clc
            close all
            fprintf("== Test for Logger == \n")
            
            dt = 0.01;
            logTimeInterval = 0.01;
            
            simClock = Clock();
            logger = Logger();
            logger.attachSimClock(simClock);
            logger.turnOn(logTimeInterval);
            
            A = [1, dt; 0, 1];
            B = [0; dt];
            x = [0; 0];
            u = 1;
            
            tic
            for i = 1:100
                logger.forward({'time', 'state', 'control'}, {simClock.time, x, u});
                x = A*x + B*u;
                simClock.elapse(dt);
            end
            loggedData = logger.get({'time', 'state'});
            [time, state] = loggedData{:};
            elapsedTime = toc;
            fprintf("ElapsedTime: %.2f [s] \n", elapsedTime)
            
            figure();
            hold on
            plot(time, state(1, :), 'DisplayName', "Pos. [m]")
            plot(time, state(2, :), "DisplayName", "Vel. [m/s]")
            xlabel("Time [s]")
            ylabel("State")
            grid on
            legend()
        end
    end
end