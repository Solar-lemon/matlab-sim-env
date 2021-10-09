classdef MultiStateDynSystem < BaseSystem
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
            
            obj = obj@BaseSystem(initialState);
            obj.name = 'multiStateDynSystem';
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
            fprintf("Attach a derivFun or implement the derivative method! \n")
            out = cell(size(obj.initialState));
            for k = 1:numel(out)
                out{k} = zeros(size(obj.initialState{k}));
            end
        end
        
        % implement
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            if isa(obj.derivFun, 'BaseFunction')
                derivList = obj.derivFun.forward(obj.stateValueList{:}, varargin{:});
            else
                derivList = obj.derivFun(obj.stateValueList{:}, varargin{:});
            end
            
            for k = 1:numel(obj.stateVarList)
                obj.stateVarList{k}.forward(derivList{k});
            end
            
            keySet = {'time'};
            valueSet = {obj.simClock.time};
            
            stateKeySet = cell(1, obj.stateVarNum);
            for i = 1:obj.stateVarNum
                stateKeySet{i} = ['state', num2str(i)];
            end
            inputKeySet = cell(size(varargin));
            for i = 1:numel(varargin)
                inputKeySet{i} = ['input', num2str(i)];
            end
           
            keySet = [keySet, stateKeySet, inputKeySet];
            valueSet = [valueSet, obj.stateValueList, varargin];
            obj.logger.forward(keySet, valueSet);
            
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
            loggedData = system.history('time', 'state1', 'state2');
            [timeList, posList, velList] = loggedData{:};
            
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