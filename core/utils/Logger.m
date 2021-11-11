classdef Logger < handle
    properties
        data
        name = "Logger"
        
        simClock
        timer
        isInitialized = false
    end
    methods
        function obj = Logger()
            obj.data = containers.Map();
        end
        
        function clear(obj)
            obj.data.remove(obj.data.keys());
        end
        
        function out = isempty(obj)
            out = isempty(obj.data);
        end
        
        function out = numel(obj)
            if obj.data.isempty()
                out = 0;
                return
            end
            keys = obj.data.keys();
            out = obj.data(keys{1}).numel();
        end
        
        function append(obj, keySet, valueSet)
            for i = 1:numel(keySet)
                key = keySet{i};
                try
                    list = obj.data(key);
                catch
                    list = List();
                    obj.data(key) = list;
                end
                list.append(valueSet{i});
            end
        end
        
        function out = get(obj, keySet)
            if nargin < 2
                keySet = obj.data.keys();
            end
            
            if numel(keySet) == 1
                out = obj.data(keySet{1}).toMatrix();
            else
                out = cell(1, numel(keySet));
                for i = 1:numel(keySet)
                    key = keySet{i};
                    out{i} = obj.data(key).toMatrix();
                end
            end
        end
        
        function out = keys(obj)
            out = obj.data.keys();
        end
    end
    methods(Static)
        function test()
            clc
            close all
            fprintf("== Test for Logger == \n")
            
            dt = 0.01;
            simClock = SimClock();
            logger = Logger();
            
            A = [1, dt; 0, 1];
            B = [0; dt];
            x = [0; 0];
            u = 1;
            
            tic
            for i = 1:100
                logger.append({'time', 'state', 'control'}, {simClock.time, x, u});
                x = A*x + B*u;
                simClock.elapse(dt);
            end
            elapsedTime = toc;
            fprintf("ElapsedTime: %.2f [s] \n", elapsedTime)
            
            loggedData = logger.get();
            time = loggedData('time');
            state = loggedData('state');
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