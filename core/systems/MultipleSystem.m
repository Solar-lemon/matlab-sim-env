classdef MultipleSystem < BaseSystem
    properties
        systemList
        systemNum
        discSystemList
        discSystemNum
    end
    methods
        function obj = MultipleSystem()
            obj = obj@BaseSystem();
            obj.name = 'multipleSystem';
        end
        
        % override
        function reset(obj)
            reset@BaseSystem(obj);
            for k = 1:obj.systemNum
                obj.systemList{k}.reset();
            end
            for k = 1:obj.discSystemNum
                obj.discSystemList{k}.reset();
            end
        end
        
        function attachDynSystems(obj, systemList)
            tempList = cell(size(systemList));
            tempNum = 0;
            for k = 1:numel(systemList)
                if isa(systemList{k}, 'BaseSystem')
                    tempNum = tempNum + 1;
                    tempList{tempNum} = systemList{k};
                end
            end
            
            obj.systemList = tempList(1:tempNum);
            obj.systemNum  = tempNum;
            
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
        
        function attachDiscSystems(obj, discSystemList)
            obj.discSystemList = discSystemList;
            obj.discSystemNum = numel(discSystemList);
        end
        
        % override
        function applyTime(obj, timeFeed)
            applyTime@BaseSystem(obj, timeFeed);
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.applyTime(timeFeed);
            end
            for k = 1:numel(obj.discSystemList)
                obj.discSystemList{k}.applyTime(timeFeed);
            end
        end
        
        % override
        function startLogging(obj, logTimeInterval)
            startLogging@BaseSystem(obj, logTimeInterval);
            for k = 1:obj.systemNum
                obj.systemList{k}.startLogging(logTimeInterval);
            end
        end
        
        % override
        function finishLogging(obj)
            finishLogging@BaseSystem(obj);
            for k = 1:obj.systemNum
                obj.systemList{k}.finishLogging();
            end
        end
        
        % to be implemented
        function forward(obj, varargin)
            assert(~isempty(obj.systemList),...
                "Attach dynamic systems first")
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.forwardWrapper(varargin);
            end
        end
        
        % implement
        function [toStop, flag] = checkStopCondition(obj)
            toStopList = false(obj.systemNum, 1);
            for k = 1:obj.systemNum
                toStopList(k) = obj.systemList{k}.checkStopCondition();
            end
            
            toStop = any(toStopList);
            if toStop
                obj.flag = find(toStopList);
            end
            
            if nargout > 1
                flag = obj.flag;
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
            system1 = DynSystem([0; 0], SecondOrderDynFun(0.3, 2));
            system2 = DynSystem([0; 0], SecondOrderDynFun(0.5, 2));
            system3 = DynSystem([0; 0], SecondOrderDynFun(0.8, 2));
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