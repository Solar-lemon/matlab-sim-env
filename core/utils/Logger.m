classdef Logger < handle
    properties
        simClock
        timer
        data
        varNamesAreInitialized = false
    end
    properties(Dependent)
        logTimeInterval
        dataNum
        matValues
    end
    
    methods
        function obj = Logger()
            obj.data = MatStackedData();
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end
        
        function reset(obj)
            obj.timer = [];
            obj.data.clear();
            obj.varNamesAreInitialized = false;
        end
        
        function turnOn(obj, logTimeInterval)
            assert(~isempty(obj.simClock), "[Logger] Attach a clock first.\n")
            obj.timer = Timer(logTimeInterval);
            obj.timer.attachSimClock(obj.simClock);
            obj.timer.turnOn();
        end
        
        function turnOff(obj)
            obj.timer = [];
        end
        
        function out = isempty(obj)
            out = isempty(obj.data);
        end
        
        function out = toLog(obj)
            obj.timer.forward();
            out = ~isempty(obj.timer) && obj.timer.checkEvent();
        end
        
        function forward(obj, varargin)
            obj.timer.forward();
            if ~isempty(obj.timer) && obj.timer.checkEvent()
                obj.data.append(obj.simClock.time, varargin{:});
            end
        end
        
        function forwardVarNames(obj, varargin)
            names = [{'time'}, varargin(:)'];
            if ~obj.varNamesAreInitialized
                obj.data.setVarNames(names{:});
                obj.varNamesAreInitialized = true;
            end
        end
        
        function out = matValuesByVarNames(obj, varargin)
            % out = matValueForName1 for a single name
            % out = {matValueForName1, ... matValueForNameN} for multiple
            % names
            out = obj.data.matValuesByVarNames(varargin{:});
        end
        
        function save(obj, filePath)
            if isempty(obj.data)
                fprintf("There is no data to save \n");
                return
            end
            if nargin < 2 || isempty(filePath)
                filePath = 'data/logData/logger.mat';
            end
            obj.data.save(filePath);
        end
        
        function load(obj, filePath)
            if nargin < 2 || isempty(filePath)
                filePath = 'data/logData/logger.mat';
            end
            obj.data.load(filePath);
        end
    end
    
    % set and get methods
    methods
        function out = get.dataNum(obj)
            out = obj.data.dataNum;
        end
        
        function out = get.matValues(obj)
            out = obj.data.matValues;
        end
        
        function out = get.logTimeInterval(obj)
            if isempty(obj.timer)
                out = [];
            else
                out = obj.timer.eventTimeInterval;
            end
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for Logger == \n")
            dt = 0.01;
            timeResolution = 1e-6;
            logTimeInterval = 0.1;
            
            simClock = Clock(0, timeResolution);
            logger = Logger();
            logger.attachSimClock(simClock);
            logger.turnOn(logTimeInterval);
            
            pos = [0; 0];
            vel = [1; 0];
            for i = 1:100
                logger.forward(pos, vel);
                logger.forwardVarNames('pos', 'vel');
                
                pos = pos + vel*dt;
                simClock.elapse(dt);
            end
            [timeList, posList, velList] = logger.matValues{:};
            fprintf("size(timeList): (%d, %d) \n", ...
                size(timeList, 1), size(timeList, 2))
            fprintf("size(posList): (%d, %d) \n", ...
                size(posList, 1), size(posList, 2))
            fprintf("size(velList): (%d, %d) \n \n", ...
                size(velList, 1), size(velList, 2))
            
            fprintf("== Using matValuesByNames(varargin) == \n")
            posList = logger.matValuesByVarNames('pos');
            velList = logger.matValuesByVarNames('vel');
            fprintf("posList = logger.matValuesByNames('pos') \n")
            fprintf("size(posList): (%d, %d) \n", ...
                size(posList, 1), size(posList, 2))
            fprintf("velList = logger.matValuesByNames('vel') \n")
            fprintf("size(velList): (%d, %d) \n", ...
                size(velList, 1), size(velList, 2))
        end
    end
end