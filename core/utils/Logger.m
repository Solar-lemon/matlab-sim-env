classdef Logger < handle
    properties
        data
        isOperating logical = true;
    end
    properties(Access=protected)
        logTimer Timer
    end
    methods
        function obj = Logger()
            obj.data = dictionary();
        end

        function attachLogTimer(obj, logTimer)
            obj.logTimer = logTimer;
        end
        
        function turnOn(obj)
            obj.isOperating = true;
        end
        
        function turnOff(obj)
            obj.isOperating = false;
        end
        
        function detachLogTimer(obj)
            obj.logTimer = [];
        end

        function clear(obj)
            obj.data = dictionary();
        end
        
        function out = isempty(obj)
            out = (numEntries(obj.data) == 0);
        end
        
        function out = numel(obj)
            if isempty(obj.data)
                out = 0;
                return
            end
            dataValues = values(obj.data);
            out = numel(dataValues{1});
        end
        
        function append(obj, varargin)
            % append(var1, value1, var2, value2, ..., varN, valueN)
            d = kwargsToDict(varargin{:});
            
            if obj.isOperating
                if isempty(obj.logTimer) || obj.logTimer.isEvent
                    keys = d.keys();
                    values = d.values();
                    for i = 1:numel(keys)
                        try
                            obj.data(keys{i}).append(values{i});
                        catch
                            obj.data(keys{i}) = List();
                            obj.data(keys{i}).append(values{i});
                        end
                    end
                end
            end
        end
        
        function out = get(obj, varargin)
            if obj.isempty()
                out = [];
                return
            end

            if numel(varargin) == 1
                out = toArray(obj.data(varargin{1}));
                return
            else
                if isempty(varargin)
                    varargin = obj.data.keys();
                end
                out = dictionary();
                for i = 1:numel(varargin)
                    key = varargin{i};
                    out(key) = {toArray(obj.data(key))};
                end
            end
        end
        
        function out = keys(obj)
            out = obj.data.keys();
        end

        function save(obj, filename, dataGroup)
            % filename: name of the HDF5
            arguments
                obj
                filename
                dataGroup = ''
            end

            keys = obj.keys();
            if ~isempty(keys)
                for i = 1:numel(keys)
                    key = keys(i);
                    varData = obj.get(key);
                    h5create(filename, strcat(dataGroup, '/', key), size(varData))
                    h5write(filename, strcat(dataGroup, '/', key), varData)
                end
            end
        end

        function load(obj, filename, dataGroup)
            arguments
                obj
                filename
                dataGroup = ''
            end

            obj.data = dictionary();
            try
                info = h5info(filename, strcat(dataGroup, '/'));
                datasets = info.Datasets;
                for i = 1:numel(datasets)
                    key = datasets(i).Name;
                    varData = h5read(filename, strcat(dataGroup, '/', key));
                    obj.data(key) = List(varData);
                end
            catch
            end
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
                logger.append(time=simClock.time, state=x, control=u);
                x = A*x + B*u;
                simClock.elapse(dt);
            end
            elapsedTime = toc;
            fprintf("ElapsedTime: %.2f [s] \n", elapsedTime)

            time = logger.get('time');
            state = logger.get('state');

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