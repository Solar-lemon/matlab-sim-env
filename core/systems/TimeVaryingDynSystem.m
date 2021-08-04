classdef TimeVaryingDynSystem < BaseSystem
    properties
        initialState
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
            obj.name = 'timeVaryingDynSystem';
            obj.initialState = initialState;
            
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
            obj.stateVar.setFlatValue(stateFeed);
        end
        
        % override
        function rk4Update1(obj, t0, dt)
            obj.stateVar.rk4Update1(dt);
            obj.applyTime(t0 + dt/2);
        end
        
        % override
        function rk4Update2(obj, t0, dt)
            obj.stateVar.rk4Update2(dt);
            obj.applyTime(t0 + dt/2);
        end
        
        % override
        function rk4Update3(obj, t0, dt)
            obj.stateVar.rk4Update3(dt);
            obj.applyTime(t0 + dt - 10*eps(t0 + dt/2));
        end
        
        % override
        function rk4Update4(obj, t0, dt)
            obj.stateVar.rk4Update4(dt);
            obj.applyTime(t0 + dt);
        end
        
        % override
        function out = flatDeriv(obj)
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
            obj.stateVar.forward(obj.time, varargin{:});
            if obj.logger.toLog()
                obj.logger.forward(obj.state, varargin{:});
            end
            
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