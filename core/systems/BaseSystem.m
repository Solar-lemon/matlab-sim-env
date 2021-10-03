classdef(Abstract) BaseSystem < handle
    properties
        simClock
        stateVarList
        stateVarNum
        stateNum
        stateIndex
        logger
        name = 'baseSystem'
        flag = 0
    end
    properties(Dependent)
        time
        state
        stateValueList
        history
    end
    methods
        function obj = BaseSystem(initialState)
            % initialState: an array or
            % cell array {state1, state2, ..., stateN}
            if nargin < 1 || isempty(initialState)
                initialState = [];
            end
            
            if isempty(initialState)
                stateVarList = [];
            elseif isa(initialState, 'numeric')
                stateVarList = {StateVariable(initialState)};
            elseif isa(initialState, 'cell')
                stateVarNum = numel(initialState);
                stateVarList = cell(1, stateVarNum);
                for k = 1:stateVarNum
                    stateVarList{k} = StateVariable(initialState{k});
                end
            end
            obj.stateVarList = stateVarList;
            obj.indexing(stateVarList);
            obj.logger = Logger();
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
            obj.logger.attachSimClock(simClock);
        end
        
        function reset(obj)
            obj.logger.reset();
        end
        
        function applyState(obj, stateFeed)
            for k = 1:obj.stateVarNum
                index = obj.stateIndex{k};
                obj.stateVarList{k}.setFlatValue(stateFeed(index, 1));
            end
        end
        
        function out = flatDeriv(obj)
            out = nan(obj.stateNum, 1);
            for k = 1:obj.stateVarNum
                stateVar = obj.stateVarList{k};
                index = obj.stateIndex{k};
                out(index, 1) = stateVar.flatDeriv;
            end
        end
        
        function forwardWrapper(obj, inputs)
            processedInputs = cell(size(inputs));
            for i = 1:numel(inputs)
                if isa(inputs{i}, 'numeric')
                    processedInputs{i} = inputs{i};
                elseif isa(inputs{i}, 'function_handle')
                    processedInputs{i} = inputs{i}(obj.simClock.time);
                elseif isa(inputs{i}, 'BaseFunction')
                    processedInputs{i} = inputs{i}.forward(obj.simClock.time);
                end
            end
            obj.forward(processedInputs{:});
        end
        
        function step(obj, dt, inputs)
            t0 = obj.simClock.time;
            
            obj.forwardWrapper(inputs);
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.rk4Update1(dt);
            end
            
            obj.simClock.applyTime(t0 + dt/2);
            obj.forwardWrapper(inputs);
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.rk4Update2(dt);
            end
            
            obj.simClock.applyTime(t0 + dt/2);
            obj.forwardWrapper(inputs);
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.rk4Update3(dt);
            end
            
            obj.simClock.applyTime(t0 + dt - 10*obj.simClock.timeResolution);
            obj.forwardWrapper(inputs);
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.rk4Update4(dt);
            end
            
            obj.simClock.applyTime(t0 + dt);
        end
        
        function startLogging(obj, logTimeInterval)
            obj.logger.turnOn(logTimeInterval);
        end
        
        function finishLogging(obj)
            obj.logger.turnOff();
        end
        
        function out = historyByVarNames(obj, varargin)
            out = obj.logger.matValuesByVarNames(varargin{:});
        end
        
        % to be implemented
        function out = output(obj)
            % implement this method if needed
        end
        
        % to be implemented
        function [toStop, flag] = checkStopCondition(obj)
            % implement this method if needed
            toStop = false;
            
            if nargout > 1
                flag = obj.flag;
            end
        end
        
        % to be implemented
        function plot(obj)
            
        end
        
        % to be implemented
        function report(obj)
            
        end
    end
    
    methods
        function save(obj, filePath)
            if nargin < 2 || ismepty(filePath)
                filePath = ['data/logData/', obj.name, '.mat'];
            end
            obj.logger.save(filePath);
            
            file = matfile(filePath, 'Writable', true);
            file.state = obj.state;
        end
        
        function load(obj, filePath)
            if nargin < 2 || ismepty(filePath)
                filePath = ['data/logData/', obj.name, '.mat'];
            end
            obj.logger.load(filePath);
            
            file = matfile(filePath);
            obj.applyState(file.state);
        end
    end
    
    % set and get methods
    methods
        function out = get.time(obj)
            out = obj.simClock.time;
        end
        
        function out = get.state(obj)
            out = stateFlatValue(obj);
        end
        
        function out = get.stateValueList(obj)
            out = cell(1, obj.stateVarNum);
            for k = 1:obj.stateVarNum
                out{k} = obj.stateVarList{k}.value;
            end
        end
        
        function out = get.history(obj)
            assert(obj.logger.dataNum > 0,...
                "There is no simulation data to save \n")
            out = obj.logger.matValues;
        end
    end
    
    methods(Access=protected)
        function indexing(obj, stateVarList)
            obj.stateVarNum = numel(stateVarList);
            obj.stateIndex  = cell(size(stateVarList));
            lastIndex = 0;
            for k = 1:obj.stateVarNum
                obj.stateIndex{k} = lastIndex + 1:lastIndex + numel(stateVarList{k});
                lastIndex = lastIndex + numel(stateVarList{k});
            end
            obj.stateNum = lastIndex;
        end
        
        function out = stateFlatValue(obj)
            out = nan(obj.stateNum, 1);
            for k = 1:obj.stateVarNum
                index = obj.stateIndex{k};
                out(index, 1) = obj.stateVarList{k}.flatValue;
            end
        end
    end
    
    methods(Abstract)
        % to be implemented
        forward(varargin);
    end
end