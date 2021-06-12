classdef(Abstract) SequentialSystem < BaseSystem
    properties
        systemList
        systemNum
    end
    methods
        function obj = SequentialSystem()
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
            applyTime(obj, timeFeed);
            out = stateDeriv@BaseSystem(obj, stateFeed, timeFeed);
        end
        
        % override
        function applyTime(obj, timeFeed)
            obj.time = timeFeed;
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.time = timeFeed;
            end
        end
        
        function saveHistory(obj)
            for k = 1:numel(obj.systemList)
                obj.systemList{k}.saveHistory();
            end
        end
        
        function step(obj, dt, saveHistory, varargin)
            if nargin < 3 || isempty(saveHistory)
                saveHistory = true;
            end
            obj.forward(varargin{:});
            if saveHistory
                obj.saveHistory();
            end
            
            % remember initial state values
            t0 = obj.time;
            y0 = obj.state;
            
            k1 = obj.stateDeriv();
            k2 = obj.stateDeriv(y0 + dt/2*k1, t0 + dt/2);
            k3 = obj.stateDeriv(y0 + dt/2*k2, t0 + dt/2);
            k4 = obj.stateDeriv(y0 + dt*k3, t0 + dt);
            
            % update time and states
            t = t0 + dt;
            y = y0 + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
            obj.applyTime(t);
            obj.applyState(y);
            obj.time = t;
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = true;
            end
            iterNum = round(time/dt);
            for i = 1:iterNum
                step(obj, dt, saveHistory, varargin{:});
            end
        end
    end
end