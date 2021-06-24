classdef(Abstract) BaseSystem < handle
    properties
        time = 0
        stateVarList
        stateVarNum
        stateNum
        stateIndex
        logTimer = []
        name
    end
    methods
        function obj = BaseSystem(stateVarList, name)
            if nargin < 2
                name = 'BaseSystem';
            end
            if nargin < 1
                stateVarList = [];
            end
            obj.stateVarList = stateVarList;
            obj.indexing(stateVarList);
            obj.name = name;
        end
        
        function reset(obj)
            obj.time = 0;
        end
        
        function out = state(obj)
            out = nan(obj.stateNum, 1);
            for k = 1:numel(obj.stateVarList)
                stateVar = obj.stateVarList{k};
                index = obj.stateIndex{k};
                out(index, 1) = stateVar.flatValue;
            end
        end
        
        function applyState(obj, stateFeed)
            for k = 1:numel(obj.stateVarList)
                stateVar = obj.stateVarList{k};
                index = obj.stateIndex{k};
                stateVar.setFlatValue(stateFeed(index, 1));
            end
        end
        
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
        end
        
        function out = stateDeriv(obj, stateFeed, timeFeed, varargin)
            % Assume that stateFeed and timeFeed are always given
            % together
            if nargin < 3
                stateFeed = [];
                timeFeed = [];
            end
            if ~isempty(stateFeed) && ~isempty(timeFeed)
                applyState(obj, stateFeed);
                applyTime(obj, timeFeed);
            end
            forward(obj, varargin{:});
            obj.logTimer.forward(obj.time);
            
            out = nan(obj.stateNum, 1);
            for k = 1:numel(obj.stateVarList)
                stateVar = obj.stateVarList{k};
                index = obj.stateIndex{k};
                out(index, 1) = stateVar.flatDeriv;
            end
            
            if obj.logTimer.checkEvent()
                saveHistory(obj);
            end
        end
        
        function startLogging(obj, interval)
            if isempty(obj.logTimer)
                obj.logTimer = Timer(interval);
            end
            obj.logTimer.eventTimeInterval = interval;
            obj.logTimer.turnOn(true);
            obj.logTimer.forward(obj.time);
        end
        
        function finishLogging(obj)
            obj.logTimer.turnOff();
        end
        
        % to be overriden
        function saveHistory(obj)
            % implement this method if needed
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
    end
    
    methods(Abstract)
        % to be implemented
        forward(varargin);
    end
end