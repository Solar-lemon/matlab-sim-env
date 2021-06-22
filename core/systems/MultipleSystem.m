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
    
    methods(Static)
        function test()
            clc
            fprintf("== Test for MultipleSystem class == \n")
            fprintf("Unrelated systems can be simulated simply using a MultipleSystem object.\n")
            fprintf("For more complex systems, define a class that inherits MultipleSystem \n")
            fprintf("and implement a forward method. \n")
            system1 = DynSystem([0; 0], SecondOrderDyn(0.3, 2));
            system2 = DynSystem([0; 0], SecondOrderDyn(0.5, 2));
            system3 = DynSystem([0; 0], SecondOrderDyn(0.8, 2));
            multipleSystem = MultipleSystem();
            multipleSystem.attachDynSystems({system1, system2, system3});
            
            simulator = Simulator(multipleSystem);
            
            tic
            simulator.propagate(0.01, 10, true, 1);
            elapsedTime = toc;
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            
            system1.plot();
            system2.plot();
            system3.plot();
        end
    end
end