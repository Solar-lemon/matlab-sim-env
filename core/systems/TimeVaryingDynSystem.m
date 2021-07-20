classdef TimeVaryingDynSystem < BaseSystem
    properties
        initialState
        inValues
        history
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
            stateVarList = {StateVariable(initialState(:))};
            obj = obj@BaseSystem(stateVarList);
            obj.name = 'TimeVaryingDynSystem';
            obj.initialState = initialState;
            obj.history = MatStackedData();
            
            if isempty(derivFun)
                derivFun = @obj.derivative;
            end
            attachDerivFun(obj, derivFun);
            attachOutputFun(obj, outputFun);
        end
        
        % override
        function reset(obj, initialState)
            if nargin < 2
                initialState = obj.initialState;
            end
            reset@BaseSystem(obj);
            applyState(obj, initialState);
            
            obj.history.clear();
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle or BaseFunction
            % derivFun(state, time, input1, ..., inputM)
            obj.stateVar.attachDerivFun(derivFun);
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            % outputFun(state, time)
            obj.outputFun = outputFun;
        end
        
        % override
        function applyState(obj, stateFeed)
            obj.stateVar.flatValue = stateFeed;
        end
        
        % override
        function out = stateDeriv(obj, stateFeed, timeFeed, varargin)
            % Assume that stateFeed and timeFeed are always given
            % together
            applyState(obj, stateFeed);
            applyTime(obj, timeFeed);
            forward(obj, varargin{:});
            if ~isempty(obj.logTimer)
                obj.logTimer.forward(obj.time);
                if obj.logTimer.checkEvent()
                    saveHistory(obj);
                end
            end
            
            out = obj.stateVar.flatDeriv;
        end
        
        % to be implemented
        function out = derivative(obj, varargin)
            % implement this method if needed
            fprintf("Attach a derivFun or implement the derivative method! \n")
            out = zeros(size(obj.initialState));
        end
        
        % implement
        function out = forward(obj, varargin)
            % derivFun: function_handle or BaseFunction
            % derivFun(state, time, input1, ..., inputM)
            obj.inValues = varargin;
            obj.stateVar.forward(obj.time, varargin{:});
            if nargout > 0
                out = obj.output;
            end
        end
        
        % implement
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.state, obj.time);
            else
                out = obj.outputFun(obj.state, obj.time);
            end
        end
    end
    
    % set and get methods
    methods
        function out = get.stateVar(obj)
            out = obj.stateVarList{1};
        end
    end
    
    methods(Access=protected)
        % override
        function out = stateFlatValue(obj)
            out = obj.stateVar.value;
        end
    end
    
    methods
        % implement
        function saveHistory(obj)
            obj.history.append(obj.time, obj.state, obj.inValues{:});
        end
        
        function saveSimData(obj, folder, filename)
            if isempty(obj.history)
                fprintf("There is no simulation data to save \n");
                return
            end
            
            if nargin < 3 || isempty(filename)
                filename = ['sim_data_', obj.name, '.mat'];
            end
            if nargin < 2 || isempty(folder)
                folder = 'data/';
            end
            
            if ~isfolder(folder)
                mkdir(folder);
            end
            
            location = [folder, filename];
            simData = obj.history;
            save(location, 'simData');
        end
        
        function loadSimData(obj, folder, filename)
            if nargin < 3 || isempty(filename)
                filename = ['sim_data_', obj.name, '.mat'];
            end
            if nargin < 2 || isempty(folder)
                folder = 'data/';
            end
            
            location = [folder, filename];
            load(location, 'simData');
            obj.history = simData;
        end
        
        function fig = plot(obj, fig)
            if obj.stateNum > 4
                return
            end
            if nargin < 2
                fig = figure();
            end
            
            [timeList, stateList, controlList] = obj.history.get();
            stateNum = obj.stateNum;
            inputNum = size(controlList, 1);
            
            figure(fig);
            subplot(2, 1, 1)
            hold on
            for k = 1:stateNum
                plot(timeList, stateList(k, :), 'DisplayName', sprintf('x%d', k))
            end
            title('State')
            xlabel('Time')
            ylabel('State')
            grid on
            box on
            legend()
            
            subplot(2, 1, 2)
            hold on
            for k = 1:inputNum
                plot(timeList, controlList(k, :), 'DisplayName', sprintf('u%d', k))
            end
            title('Control input')
            xlabel('Time')
            ylabel('Control input')
            grid on
            box on
            legend()
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for TimeVaryingDynSystem == \n')
            derivFun = @(x, t, u) -1/(1 + t)^2*x + u;
            system = TimeVaryingDynSystem(1, derivFun);
            
            tic
            u_zero = 0;
            Simulator(system).propagate(0.01, 10, true, u_zero);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            system.plot();
        end
    end
end