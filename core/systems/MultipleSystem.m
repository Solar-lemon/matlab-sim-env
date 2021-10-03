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
        function attachSimClock(obj, simClock)
            attachSimClock@BaseSystem(obj, simClock);
            for k = 1:obj.systemNum
                obj.systemList{k}.attachSimClock(simClock);
            end
            for k = 1:obj.discSystemNum
                obj.discSystemList{k}.attachSimClock(simClock);
            end
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
            lastSVI = obj.stateVarNum; % lastStateVarIndex
            lastSI = obj.stateNum; % lastStateIndex
            
            stateVarIsNotEmpty = false(1, numel(systemList));
            for k = 1:numel(systemList)
                if isa(systemList{k}, 'BaseSystem') && ~isempty(systemList{k}.stateVarList)
                    stateVarIsNotEmpty(k) = true;
                end
            end
            newSysList = systemList(stateVarIsNotEmpty);
            newSysNum = numel(newSysList);
            
            obj.systemList = [obj.systemList, newSysList];
            obj.systemNum = numel(obj.systemList);
            
            obj.stateVarList = [obj.stateVarList, cell(1, newSysNum)];
            obj.stateIndex = [obj.stateIndex, cell(1, newSysNum)];
            for k = 1:newSysNum
                system = newSysList{k};
                obj.stateVarList(lastSVI + 1:lastSVI + system.stateVarNum) =...
                    system.stateVarList;
                updatedStateIndex = cellfun(@(x) x + lastSI, system.stateIndex,...
                    'UniformOutput', false);
                obj.stateIndex(lastSVI + 1:lastSVI + system.stateVarNum) =...
                    updatedStateIndex;
                
                lastSVI = lastSVI + system.stateVarNum;
                lastSI  = lastSI + system.stateNum;
            end
            obj.stateVarNum  = lastSVI;
            obj.stateNum     = lastSI;
        end
        
        function attachDiscSystems(obj, discSystemList)
            obj.discSystemList = [obj.discSystemList, discSystemList];
            obj.discSystemNum = numel(obj.discSystemList);
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