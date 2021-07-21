classdef(Abstract) BaseSystem < handle
    properties
        time = 0
        stateVarList
        stateVarNum
        stateNum
        stateIndex
        logger
        name = 'BaseSystem'
        flag = 0
    end
    properties(Dependent)
        state
        stateValueList
        history
    end
    methods
        function obj = BaseSystem(stateVarList)
            if nargin < 1
                stateVarList = [];
            end
            obj.stateVarList = stateVarList;
            obj.indexing(stateVarList);
            obj.logger = Logger();
        end
        
        function reset(obj)
            obj.time = 0;
            obj.logger.reset();
        end
        
        function applyState(obj, stateFeed)
            for k = 1:obj.stateVarNum
                index = obj.stateIndex{k};
                obj.stateVarList{k}.flatValue = stateFeed(index, 1);
            end
        end
        
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
            obj.logger.applyTime(timeFeed);
        end
        
        function out = stateDeriv(obj, stateFeed, timeFeed, varargin)
            % Assume that stateFeed and timeFeed are always given
            % together
            applyState(obj, stateFeed);
            applyTime(obj, timeFeed);
            forward(obj, varargin{:});
            
            out = nan(obj.stateNum, 1);
            for k = 1:obj.stateVarNum
                stateVar = obj.stateVarList{k};
                index = obj.stateIndex{k};
                out(index, 1) = stateVar.flatDeriv;
            end
        end
        
        function startLogging(obj, logTimeInterval)
            obj.logger.turnOn(logTimeInterval);
        end
        
        function finishLogging(obj)
            obj.logger.turnOff();
        end
        
        function out = historyByName(obj, varargin)
            out = obj.logger.valueListByNames(varargin{:});
        end
        
        % to be implemented
        function out = output(obj)
            % implement this method if needed
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
    end
    
    % set and get methods
    methods
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
            out = obj.logger.valueList;
        end
    end
    
    % set and get methods
    methods
        function out = get.state(obj)
            out = stateFlatValue(obj);
        end
        
        function out = get.stateValueList(obj)
            out = cell(1, obj.stateVarNum);
            for k = 1:obj.stateVarNum
                out{k} = obj.stateVarList{k}.value;
            end
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