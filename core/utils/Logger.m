classdef Logger < handle
    properties
        time = 0
        timer
        history
        nameIsInitialized = false
        varNameList
    end
    properties(Dependent)
        dataNum
        valueList
    end
    
    methods
        function obj = Logger()
            obj.history = MatStackedData();
        end
        
        function reset(obj)
            obj.time = 0;
            if ~isempty(obj.timer)
                obj.timer.turnOff();
            end
            obj.history.clear();
            obj.nameIsInitialized = false;
        end
        
        function turnOn(obj, logTimeInterval)
            if isempty(obj.timer)
                obj.timer = Timer(logTimeInterval);
            end
            obj.timer.eventTimeInterval = logTimeInterval;
            obj.timer.turnOn(obj.time, true);
        end
        
        function turnOff(obj)
            obj.timer.turnOff();
        end
        
        function out = isempty(obj)
            out = (obj.dataNum == 0);
        end
        
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
        end
        
        function forward(obj, varargin)
            if ~isempty(obj.timer)
                obj.timer.forward(obj.time);
                if obj.timer.checkEvent()
                    obj.history.append(obj.time, varargin{:});
                end
            end
        end
        
        function forwardNames(obj, varargin)
            names = [{'time'}, varargin(:)'];
            if ~obj.nameIsInitialized
                index = 1:numel(names);
                obj.varNameList = containers.Map(...
                    names, num2cell(index));
                obj.nameIsInitialized = true;
            end
        end
        
        function out = valueListByNames(obj, varargin)
            assert(~isempty(obj.varNameList),...
                "Define variable names first.")
            indices = cell2mat(obj.varNameList.values(varargin));
            out = obj.valueList(indices);
            if numel(indices) == 1
                out = out{:};
            end
        end
        
        function load(obj, valueList)
            obj.history.append(valueList{:});
        end
    end
    
    % set and get methods
    methods
        function out = get.dataNum(obj)
            out = obj.history.dataNum;
        end
        
        function out = get.valueList(obj)
            out = obj.history.valueList;
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for Logger == \n")
            dt = 0.01;
            logger = Logger();
            logger.turnOn(dt);
            
            time = 0;
            pos = [0; 0];
            vel = [1; 0];
            for i = 1:100
                logger.applyTime(time);
                logger.forward(pos, vel);
                logger.forwardNames('pos', 'vel');
                
                pos = pos + vel*dt;
                time = time + dt;
            end
            [timeList, posList, velList] = logger.valueList{:};
            fprintf("size(timeList): (%d, %d) \n", ...
                size(timeList, 1), size(timeList, 2))
            fprintf("size(posList): (%d, %d) \n", ...
                size(posList, 1), size(posList, 2))
            fprintf("size(velList): (%d, %d) \n \n", ...
                size(velList, 1), size(velList, 2))
            
            fprintf("== Using valueListByNames(varargin) == \n")
            posList = logger.valueListByNames('pos');
            velList = logger.valueListByNames('vel');
            fprintf("posList = logger.valueListByNames('pos') \n")
            fprintf("size(posList): (%d, %d) \n", ...
                size(posList, 1), size(posList, 2))
            fprintf("velList = logger.valueListByNames('vel') \n")
            fprintf("size(velList): (%d, %d) \n", ...
                size(velList, 1), size(velList, 2))
        end
    end
end