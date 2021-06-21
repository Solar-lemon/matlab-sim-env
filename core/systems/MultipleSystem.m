classdef MultipleSystem < BaseSystem
    properties
        systemList
        systemNum
    end
    methods
        function obj = MultipleSystem()
            obj = obj@BaseSystem();
        end
        
        function reset(obj)
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.reset();
            end
        end
        
        function attachDynSystems(obj, systemList)
            obj.systemList = systemList;
            obj.systemNum  = numel(systemList);
            
            stateVarNum = 0;
            for k = 1:obj.systemNum
                system = obj.systemList{k};
                if ~isempty(system.stateVarList)
                    stateVarNum = stateVarNum + system.stateVarNum;
                end
            end
            
            stateVarList = cell(1, stateVarNum);
            stateIndex   = cell(1, stateVarNum);
            lastSVI = 0; % lastStateVarIndex
            lastSI = 0;  % lastStateIndex
            for k = 1:obj.systemNum
                system = obj.systemList{k};
                if ~isempty(system.stateVarList)
                    stateVarList(lastSVI + 1:lastSVI + system.stateVarNum) =...
                        system.stateVarList;
                    updatedStateIndex = cellfun(@(x) x + lastSI, system.stateIndex,...
                        'UniformOutput', false);
                    stateIndex(lastSVI + 1:lastSVI + system.stateVarNum) =...
                        updatedStateIndex;
                    
                    lastSVI = lastSVI + system.stateVarNum;
                    lastSI  = lastSI + system.stateNum;
                end
            end
            obj.stateVarList = stateVarList;
            obj.stateIndex   = stateIndex;
            obj.stateVarNum  = lastSVI;
            obj.stateNum     = lastSI;
        end
        
        % override
        function out = stateDeriv(obj, stateFeed, timeFeed, varargin)
            assert(~isempty(obj.systemList), 'Attach dynamic systems first')
            if nargin < 3
                stateFeed = [];
                timeFeed = [];
            end
            if ~isempty(timeFeed)
                applyTime(obj, timeFeed);
            end
            out = stateDeriv@BaseSystem(obj, stateFeed, timeFeed, varargin{:});
        end
        
        % override
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.applyTime(timeFeed);
            end
        end
        
        function saveHistory(obj)
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.saveHistory();
            end
        end
        
        % to be overriden
        function forward(obj, varargin)
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.forward(varargin{:});
            end
        end
    end
end