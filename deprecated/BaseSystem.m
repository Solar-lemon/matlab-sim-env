classdef BaseSystem < SimObject
    properties
        name = 'baseSystem'
        stateVarList
        stateIndex
        stateVarNum
        stateNum
    end
    properties(Dependent)
        state
        deriv
    end
    methods
        function obj = BaseSystem(varargin)
            % initialState: an array or
            % cell array {state1, state2, ..., stateN}
            if nargin < 1
                initialStates = {};
            else
                initialStates = varargin;
            end
            
            obj.stateVarList = List();
            obj.stateIndex = List();
            
            lastIndex = 0;
            if ~isempty(initialStates)
                for i = 1:numel(initialStates)
                    var = StateVariable(initialStates{i});
                    index = lastIndex + (1:lastIndex + numel(var));
                    obj.stateVarList.append(var);
                    obj.stateIndex.append(index);
                    lastIndex = lastIndex + numel(var);
                end
            end
            
            obj.stateVarNum = numel(obj.stateVarList);
            obj.stateNum = lastIndex;
        end
        
        function setState(obj, varargin)
            states = varargin;
            if numel(states) > 0
                for i = 1:numel(states)
                    obj.stateVarList.get(i).applyState(states{i});
                end
            end
        end
        
        function step(obj, dt, varargin)
            t0 = obj.simClock.time;
            
            obj.logTimer.forward();
            obj.forward(varargin{:});
            for i = 1:numel(obj.stateVarList)
                obj.stateVarList.get(i).rk4Update1(dt);
            end
            
            obj.simClock.applyTime(t0 + dt/2);
            obj.logTimer.forward();
            obj.forward(varargin{:});
            for i = 1:numel(obj.stateVarList)
                obj.stateVarList.get(i).rk4Update2(dt);
            end
            
            obj.logTimer.forward();
            obj.forward(varargin{:});
            for i = 1:numel(obj.stateVarList)
                obj.stateVarList.get(i).rk4Update3(dt);
            end
            
            obj.simClock.applyTime(t0 + dt - 10*obj.simClock.timeRes);
            obj.logTimer.forward();
            obj.forward(varargin{:});
            for i = 1:numel(obj.stateVarList)
                obj.stateVarList.get(i).rk4Update4(dt);
            end
            
            obj.simClock.applyTime(t0 + dt);
        end
        
        function propagate(obj, dt, time, varargin)
            assert(~isempty(obj.simClock),...
                "Attach a simClock first!")
            assert(~isempty(obj.logTimer),...
                "Attach a logTimer first!")
            
            iterNum = min(round(time/dt), intmax('int32'));
            for i = 1:iterNum
                toStop = obj.checkStopCondition();
                if toStop
                    break
                end
                obj.step(dt, varargin{:});
            end
            
            obj.logTimer.forward();
            obj.forward(varargin{:});
        end
        
        function out = history(obj, varargin)
            assert(~obj.logger.isempty(),...
                "There is no simulation data recorded")
            out = obj.logger.get(varargin{:});
        end
        
        % to be implemented
        function output(obj)
            % implement this method if needed
        end
        
        % to be implemented
        function plot(obj)
            
        end
        
        % to be implemented
        function report(obj)
            fprintf("== Report for %s == \n", obj.name)
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
        function out = get.state(obj)
            out = obj.getState();
        end
        
        function out = get.deriv(obj)
            out = obj.getDeriv();
        end
        
        function out = stateFlatValue(obj)
            out = nan(obj.stateNum, 1);
            for i = 1:obj.stateVarNum
                index = obj.stateIndex.get(i);
                out(index, 1) = reshape(obj.stateVarList.get(i).state, [], 1);
            end
        end
    end
    
    methods
        function out = getState(obj, iVar)
            if nargin < 2
                iVar = 1:obj.stateVarNum;
            end
            
            if numel(iVar) == 1
                out = obj.stateVarList.get(iVar).state;
                return
            end
            
            out = cell(1, numel(iVar));
            for j = 1:numel(iVar)
                out{iVar(j)} = obj.stateVarList.get(iVar(j)).state;
            end
        end
        
        function out = getDeriv(obj, iVar)
            if nargin < 2
                iVar = 1:obj.stateVarNum;
            end
            
            if nume(iVar) == 1
                out = obj.stateVarList.get(iVar).state;
                return
            end
            
            out = cell(1, obj.stateVarNum);
            for j = 1:numel(iVar)
                out{iVar(j)} = obj.stateVarList.get(iVar(j)).deriv;
            end
        end
    end
end