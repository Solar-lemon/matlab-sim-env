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
            
            if isempty(derivFun)
                derivFun = @obj.derivative;
            end
            obj.derivFun = derivFun;
            obj.outputFun = outputFun;
        end
        
        % override
        function reset(obj, initialState)
            if nargin < 2
                initialState = obj.initialState;
            end
            reset@BaseSystem(obj);
            obj.stateVarList{1}.state = initialState;
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle or BaseFunction
            % derivFun(state, time, input1, ..., inputM)
            obj.derivFun = derivFun;
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            % outputFun(state, time)
            obj.outputFun = outputFun;
        end
        
        % to be implemented
        function out = derivative(obj, varargin)
            % implement this method if needed
            % varargin: {state, time, input1, ..., inputM}
            % out: derivState
            fprintf("Attach a derivFun or implement the derivative method! \n")
            out = zeros(size(obj.initialState));
        end
        
        % to be implemented
        function varsToLog = log(obj, varargin)
            % implement this method if needed
            % varargin: {input1, ..., inputM}
            varsToLog = {};
        end
        
        % implement
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            if isa(obj.derivFun, 'BaseFunction')
                deriv = obj.derivFun.forward(...
                    obj.stateVarList{1}.state, obj.time, varargin{:});
                obj.stateVarList{1}.forward(deriv);
            else
                deriv = obj.derivFun(...
                    obj.stateVarList{1}.state, obj.time, varargin{:});
                obj.stateVarList{1}.forward(deriv);
            end
            
            varsToLog = obj.log(varargin{:});
            obj.logger.forward(obj.stateVarList{1}.state, varargin{:}, varsToLog{:});
            
            if nargout > 0
                out = obj.output;
            end
        end
        
        % implement
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.stateVarList{1}.state, obj.time);
            else
                out = obj.outputFun(obj.stateVarList{1}.state, obj.time);
            end
        end
    end
    
    % set and get methods
    methods
        function out = get.stateVar(obj)
            out = obj.stateVarList{1};
        end
        
        % override
        function out = stateFlatValue(obj)
            out = reshape(obj.stateVarList{1}.state, [], 1);
        end
    end
    
    methods(Access=protected)
        % override
         function out = getState(obj)
            out = obj.stateVarList{1}.state;
         end
    end
    
    methods
        function fig = plot(obj, fig)
            if obj.stateNum > 4
                return
            end
            if nargin < 2
                fig = figure();
            end
            
            [timeList, stateList, controlList] = obj.history{:};
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