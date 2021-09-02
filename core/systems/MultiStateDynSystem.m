classdef MultiStateDynSystem < MultipleSystem
    properties
        initialState
        derivFun
        outputFun
    end
    methods
        function obj = MultiStateDynSystem(initialState, derivFun, outputFun)
            % initialState: cell array {state1, state2, ...}
            if nargin < 3 || isempty(outputFun)
                outputFun = @(varargin) varargin;
            end
            if nargin < 2
                derivFun = [];
            end
            
            obj = obj@MultipleSystem();
            obj.initializeState(initialState);
            obj.name = 'multiStateDynSystem';
            
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
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.setValue(initialState{k});
            end
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle or BaseFunction
            % derivList = derivFun(varargin)
            obj.derivFun = derivFun;
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            % outputList = outputFun(varargin)
            obj.outputFun = outputFun;
        end
        
        % to be implemented
        function out = derivative(obj, varargin)
            % implement this method if needed
            % varargin: {state1, ..., stateN, input1, ..., inputM}
            % out: {derivState1, ..., derivStateN}
            assert(~isempty(obj.derivFun),...
                "Attach a derivFun or implement the derivative method! \n")
            out = obj.derivFun(varargin{:});
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
                derivList = obj.derivFun.forward(obj.stateValueList{:}, varargin{:});
            else
                derivList = obj.derivFun(obj.stateValueList{:}, varargin{:});
            end
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.deriv = derivList{k};
            end
            
            if obj.logger.toLog()
                varsToLog = obj.log(varargin{:});
                obj.logger.forward(...
                    obj.stateValueList{:}, varargin{:}, varsToLog{:});
            end
            
            if nargout > 0
                out = obj.output;
            end
        end
        
        % override
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.stateValueList{:});
            else
                out = obj.outputFun(obj.stateValueList{:});
            end
        end
    end
    
    methods(Static)
        function test()
            clc
            fprintf('== Test for MultiStateDynSystem == \n')
            initialState = {[0; 0], [1; 0]};
            accel = [0; 1];
            derivFun = @(pos, vel, accel) {vel, accel};
            system = MultiStateDynSystem(...
                initialState, derivFun);
            
            dt = 0.01;
            finalTime = 10;
            
            tic
            Simulator(system).propagate(dt, finalTime, true, accel);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            [timeList, posList, velList] = system.history{:};
            
            figure();
            subplot(2, 1, 1);
            hold on
            labelList = {'x [m]', 'y [m]'};
            for k = 1:2
                plot(timeList, posList(k, :), 'DisplayName', labelList{k});
            end
            xlabel('Time [s]')
            ylabel('Position [m]')
            grid on
            box on
            legend()
            
            subplot(2, 1, 2)
            hold on
            labelList = {'v_x [m/s]', 'v_y [m/s]'};
            for k = 1:2
                plot(timeList, velList(k, :), 'DisplayName', labelList{k});
            end
            xlabel('Time [s]')
            ylabel('Velocity [m/s]')
            grid on
            box on
            legend()
        end
    end
end