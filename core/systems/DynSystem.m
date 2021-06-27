classdef DynSystem < TimeVaryingDynSystem
    properties
        
    end
    methods
        function obj = DynSystem(initialState, derivFun, outputFun, name)
            if nargin < 4 || isempty(name)
                name = 'DynSystem';
            end
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x) x;
            end
            obj = obj@TimeVaryingDynSystem(initialState, derivFun, outputFun, name);
        end
        
        % override
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.evaluate(obj.state);
            else
                out = obj.outputFun(obj.state);
            end
        end
        
        % override
        function out = forward(obj, varargin)
            % derivFun: function_handle or BaseFunction
            % derivFun(state, input1, ..., inputM)
            obj.inValues = varargin;
            obj.stateVar.forward(varargin{:});
            if nargout > 0
                out = obj.output;
            end
        end
    end
    
    methods
        % implement
        function saveHistory(obj)
            obj.history.append(obj.time, obj.state, obj.inValues{:});
        end
        
        function saveSimData(obj, folder, filename)
            if isempty(obj.history)
                disp('There is no simulation data to save');
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
            fprintf('== Test for DynSystem == \n')
            A = [0, 1;
                -1, -1];
            B = [0; 1];
            linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
            
            u_step = 1;
            y = linearSystem.forward(u_step);
            
            x_dot = linearSystem.stateVar.deriv;
            
            fprintf('A = [0, 1; -1, -1], B = [0; 1] \n')
            fprintf('linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u) \n')
            fprintf('linearSystem.forward(u_step) where u_step = 1 \n')
            fprintf('linearSystem.output: \n')
            disp(y)
            fprintf('linearSystem.stateVar.deriv: \n')
            disp(x_dot);
        end
    end
end