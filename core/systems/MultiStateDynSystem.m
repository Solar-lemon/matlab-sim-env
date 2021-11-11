classdef MultiStateDynSystem < BaseSystem
    properties
        initialStates
        derivFun
        outputFun
    end
    methods
        function obj = MultiStateDynSystem(initialStates, derivFun, outputFun)
            % initialStates: cell array {state1, state2, ...}
            if nargin < 3 || isempty(outputFun)
                outputFun = @(varargin) varargin;
            end
            if nargin < 2
                derivFun = [];
            end
            
            obj = obj@BaseSystem(initialStates{:});
            obj.name = 'multiStateDynSystem';
            obj.initialStates = initialStates;
            
            if isa(derivFun, 'SimObject')
                obj.derivFun = @derivFun.forward;
            else
                obj.derivFun = derivFun;
            end
            obj.outputFun = outputFun;
        end
        
        % override
        function reset(obj, initialStates)
            if nargin < 2
                initialStates = obj.initialStates;
            end
            reset@BaseSystem(obj);
            obj.setState(initialStates);
        end
        
        % to be implemented
        function out = derivative(obj, varargin)
            % implement this method if needed
            % varargin: {state1, ..., stateN, input1, ..., inputM}
            % out: {derivState1, ..., derivStateN}
            assert(~isempty(obj.derivFun),...
                "Attach a derivFun or implement the derivative method.")
            out = obj.derivFun(varargin{:});
        end
        
        % implement
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            states = obj.getState();
            derivs = obj.derivative(states{:}, varargin{:});
            
            for i = 1:numel(obj.stateVarList)
                obj.stateVarList.get(i).forward(derivs{i});
            end
            
            if obj.logTimer.isEvent
                stateKeySet = cell(1, obj.stateVarNum);
                for i = 1:obj.stateVarNum
                    stateKeySet{i} = ['state_', num2str(i)];
                end
                inputKeySet = cell(size(varargin));
                for i = 1:numel(varargin)
                    inputKeySet{i} = ['u_', num2str(i)];
                end
                keySet = [{'time'}, stateKeySet, inputKeySet];
                valueSet = [{obj.simClock.time}, states, varargin];
                obj.logger.append(keySet, valueSet);
            end
            
            out = obj.output();
        end
        
        % implement
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            states = obj.getState();
            out = obj.outputFun(states{:});
        end
    end
    
    methods(Static)
        function test()
            clc
            fprintf('== Test for MultiStateDynSystem == \n')
            initialStates = {[0; 0], [1; 0]};
            accel = [0; 1];
            derivFun = @(pos, vel, accel) {vel, accel};
            model = MultiStateDynSystem(...
                initialStates, derivFun);
            
            Simulator(model).propagate(0.01, 10, true, accel);
            
            timeList = model.history('time');
            posList = model.history('state_1');
            velList = model.history('state_2');
            
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