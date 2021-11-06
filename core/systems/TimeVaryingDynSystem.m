classdef TimeVaryingDynSystem < BaseSystem
    properties
        initialState
        derivFun
        outputFun
    end
    properties(Dependent)
        stateVar
    end
    
    methods
        function obj = TimeVaryingDynSystem(initialState, derivFun, outputFun)
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x, t) x;
            end
            if nargin < 2
                derivFun = [];
            end
            
            obj = obj@BaseSystem(initialState);
            obj.name = 'timeVaryingDynSystem';
            obj.initialState = initialState;
            
            if isa(derivFun, 'SimObject')
                obj.derivFun = @derivFun.forward;
            else
                obj.derivFun = derivFun;
            end
            
            obj.outputFun = outputFun;
        end
        
        % override
        function reset(obj)
            reset@BaseSystem(obj);
            obj.stateVarList.get(1).applyState(obj.initialState);
        end
        
        % override
        function setState(obj, state)
            obj.stateVarList.get(1).applyState(state);
        end
        
        % to be implemented
        function out = derivative(obj, time, state, varargin)
            assert(~isempty(obj.derivFun),...
                "Attach a derivFun or implement the derivative method!")
            out = obj.derivFun(time, state, varargin{:});
        end
        
        % implement
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            deriv = obj.derivative(...
                obj.simClock.time, obj.stateVarList.get(1).state, varargin{:});
            obj.stateVarList.get(1).forward(deriv);
            
            if obj.logTimer.isEvent
                obj.logger.append(...
                    {'time', 'state'},...
                    {obj.simClock.time, obj.stateVarList.get(1).state});
                inputKeySet = cell(size(varargin));
                for i = 1:numel(varargin)
                    inputKeySet{i} = ['u_', num2str(i)];
                end
                obj.logger.append(inputKeySet, varargin);
            end
            
            out = obj.output;
        end
        
        % implement
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            out = obj.outputFun(obj.simClock.time, obj.stateVarList.get(1).state);
        end
    end
    
    % set and get methods
    methods
        function out = get.stateVar(obj)
            out = obj.stateVarList.get(1);
        end
        
        % override
        function out = stateFlatValue(obj)
            out = reshape(obj.stateVarList.get(1).state, [], 1);
        end
    end
    
    methods(Access=protected)
        % override
        function out = getState(obj)
            out = obj.stateVarList.get(1).state;
        end
        
        % override
        function out = getDeriv(obj)
            out = obj.stateVarList.get(1).deriv;
        end
    end
    
    methods
        function figs = plot(obj, varKeys)
            if nargin < 2
                varKeys = List(obj.logger.keys());
                varKeys.remove('time');
            end
            
            figs = List();
            timeList = obj.history('time');
            
            for i = 1:numel(varKeys)
                varKey = varKeys.get(i);
                fig = figure();
                figs.append(fig);
                
                varList = obj.history(varKey);
                ind = 1:size(varList, 1);
                subplotNum = numel(ind);
                for k = 1:subplotNum
                    subplot(subplotNum, 1, k)
                    hold on
                    plot(timeList, varList(ind(k), :), 'DisplayName', "Actual")
                    xlabel("Time [s]")
                    ylabel(sprintf("%s(%d)", varKey, k))
                    grid on
                    box on
                    legend()
                end
                sgtitle(varKey)
            end
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for TimeVaryingDynSystem == \n')
            dt = 0.01;
            simClock = SimClock();
            logTimer = Timer(dt);
            logTimer.attachSimClock(simClock);
            logTimer.turnOn();
            
            derivFun = @(t, x, u) -1/(1 + t)^2*x + u;
            model = TimeVaryingDynSystem(1, derivFun);
            model.attachSimClock(simClock);
            model.attachLogTimer(logTimer);
            
            tic
            u_zero = 0;
            model.propagate(0.01, 10, u_zero);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            model.plot();
        end
    end
end