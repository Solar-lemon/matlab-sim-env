classdef(Abstract) SequentialSystem < BaseSystem
    properties
        systemList
        systemNum
    end
    methods
        function obj = SequentialSystem()
            obj = obj@BaseSystem();
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
                end
            end
            obj.stateVarList = stateVarList;
            obj.stateIndex   = stateIndex;
            obj.stateVarNum  = lastSVI;
            obj.stateNum     = lastSI;
        end
        
        % override
        function out = stateDeriv(obj, stateFeed, timeFeed)
            if isempty(obj.systemList)
                error('Attach dynamic systems first')
            end
            if nargin < 3
                stateFeed = [];
                timeFeed = [];
            end
            out = stateDeriv@BaseSystem(obj, stateFeed, timeFeed);
        end
    end
end