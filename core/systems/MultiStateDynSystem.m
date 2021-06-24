classdef MultiStateDynSystem < BaseSystem
    properties
        initialState
        derivFun
        outputFun
        inValues
        history
    end
    methods
        function obj = MultiStateDynSystem(initialState, derivFun, outputFun, name)
            % initialState: cell array {state1, state2, ...}
            if nargin < 4 || isempty(name)
                name = 'MultiStateDynSystem';
            end
            if nargin < 3 || isempty(outputFun)
                outputFun = @(varargin) varargin{:};
            end
            
            subStateVarNum = numel(initialState);
            subStateVarList = cell(1, subStateVarNum);
            for k = 1:subStateVarNum
                subStateVarList{k} = StateVariable(initialState{k});
            end
            obj = obj@BaseSystem(subStateVarList, name);
            obj.initialState = initialState;
            obj.history = VecStackedData();
            
            attachDerivFun(obj, derivFun);
            attachOutputFun(obj, outputFun);
        end
        
        function reset(obj, initialState)
            if nargin < 2
                initialState = obj.initialState;
            end
            reset@BaseSystem(obj);
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.value = initialState{k};
            end
            obj.history.clear();
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle or BaseFunction
            % derivList = derivFun(varargin)
            obj.derivFun = derivFun;
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            % varargout = outputFun(varargin)
            obj.outputFun = outputFun;
        end
        
        function out = output(obj)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.evaluate(obj.state);
            else
                out = obj.outputFun(obj.state);
            end
        end
        
        % implement
        function out = forward(obj, varargin)
            obj.inValues = varargin;
            
            stateValueList = cell(1, obj.stateVarNum);
            for k = 1:obj.stateVarNum
                stateValueList{k} = obj.stateVarList{k}.value;
            end
            derivList = obj.derivFun(stateValueList{:}, varargin{:});
            for k = 1:obj.stateVarNum
                obj.stateVarList{k}.deriv = derivList{k};
            end
            if nargout > 0
                out = obj.output;
            end
        end
    end
    
    methods
        % implement
        function saveHistory(obj)
            stateValueList = cell(1, obj.stateVarNum);
            for k = 1:obj.stateVarNum
                stateValueList{k} = obj.stateVarList{k}.value;
            end
            obj.history.append(obj.time, stateValueList{:}, obj.inValues{:});
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
            Simulator(system).propagate(dt, finalTime, true, accel);
            [timeList, posList, velList] = system.history.get();
            
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