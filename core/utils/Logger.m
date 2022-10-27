classdef Logger < handle
    properties
        data
        isOperating logical
    end
    properties(Access=protected)
        logTimer Timer
    end
    properties(Dependent)
        isEvent
    end

    methods
        function obj = Logger()
            obj.data = dictionary();
            obj.isOperating = true;
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
        
        % dynamic property
        function out = get.isEvent(obj)
            out = obj.logTimer.isEvent;
        end
        
        function append(obj, names, values)
            arguments
                obj
                names cell
                values cell
            end

            if obj.isOperating
                if isempty(obj.logTimer) || obj.logTimer.isEvent
                    for i = 1:numel(names)
                        try
                            obj.data(names{i}).append(values{i});
                        catch
                            obj.data(names{i}) = List({}, 10000);
                            obj.data(names{i}).append(values{i});
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

            if nargin < 2 || isempty(varargin)
                varargin = obj.data.keys();
            end
            if numel(varargin) == 1
                out = toArray(obj.data(varargin{1}));
                return
            end
            out = cell(size(varargin));
            for i = 1:numel(varargin)
                key = varargin{i};
                out{i} = toArray(obj.data(key));
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

            [filepath, ~, ext] = fileparts(filename);
            if ~strcmp(ext, '.hdf5')
                error("Set the extension of the file as .hdf5")
            end
            if ~isfolder(filepath)
                mkdir(filepath);
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
                logger.append({'time', 'state', 'control'}, {simClock.time, x, u});
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