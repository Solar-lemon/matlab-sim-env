classdef MultipleSystem < BaseSystem
    properties
        simObjList
        simObjNum
    end
    methods
        function obj = MultipleSystem()
            obj = obj@BaseSystem();
            obj.name = 'multipleSystem';
            obj.simObjList = List();
            obj.simObjNum = 0;
        end
        
        function attachSimObjects(obj, simObjList)
            if isa(simObjList, 'cell')
                simObjList = List(simObjList);
            end
            SVI = obj.stateVarNum; % last state var index
            SI = obj.stateNum; % last state index
            
            for i = 1:numel(simObjList)
                simObj = simObjList.get(i);
                if isa(simObj, 'SimObject')
                    obj.simObjList.append(simObj);
                    
                    if isa(simObj, 'BaseSystem')
                        obj.stateVarList.extend(simObj.stateVarList);
                        for j = 1:numel(simObj.stateIndex)
                            newIndex = SI + simObj.stateIndex.get(j);
                            obj.stateIndex.append(newIndex);
                        end
                        SVI = SVI + simObj.stateVarNum;
                        SI = SI + simObj.stateNum;
                    end
                end
            end
            obj.stateVarNum = SVI;
            obj.stateNum = SI;
            obj.simObjNum = numel(obj.simObjList);
            obj.flag = zeros(obj.simObjNum, 1);
        end
        
        % override
        function attachSimClock(obj, simClock)
            attachSimClock@BaseSystem(obj, simClock);
            for i = 1:numel(obj.simObjList)
                obj.simObjList.get(i).attachSimClock(simClock);
            end
        end
        
        % override
        function attachLogTimer(obj, logTimer)
            attachLogTimer@BaseSystem(obj, logTimer);
            for i = 1:numel(obj.simObjList)
                obj.simObjList.get(i).attachLogTimer(logTimer);
            end
        end
        
        % override
        function reset(obj)
            reset@BaseSystem(obj);
            for i = 1:numel(obj.simObjList)
                obj.simObjList.get(i).reset();
            end
        end
        
        % implement
        function [toStop, flag] = checkStopCondition(obj)
            toStopList = false(obj.simObjNum, 1);
            for i = 1:obj.simObjNum
                toStopList(i) = obj.simObjList.get(i).checkStopCondition();
            end
            
            toStop = any(toStopList);
            if toStop
                for i = 1:obj.simObjNum
                    obj.flag(i) = obj.simObjList.get(i).flag;
                end
            end
            flag = obj.flag;
        end
    end
    
    methods(Static)
        function test()
            clc
            fprintf("== Test for MultipleSystem class == \n")
            
            zeta = 0.1;
            omega = 1;
            A = [...
                0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            K = [0.4142, 1.1669];
            
            derivFun = @(x, u) A*x + B*u;
            linearSys = DynSystem([0; 1], derivFun);
            lqrControl = BaseFunction(@(y, r) -K*y);
            
            model = FeedbackControl(linearSys, lqrControl);
            
            simulator = Simulator(model);
            simulator.propagate(0.01, 10, true);
            
            linearSys.plot();
        end
    end
end