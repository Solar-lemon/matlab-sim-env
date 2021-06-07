classdef DynSystem < BaseSystem
    properties
        initialState
        inValues
        outputFun
        history
    end
    methods
        function obj = DynSystem(initialState, derivFun, outputFun, name)
            if nargin < 4 || isempty(name)
                name = 'DynSystem';
            end
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x) x;
            end
            initialState = initialState(:);
            stateVarList = {StateVariable(initialState)};
            obj = obj@BaseSystem(stateVarList, name);
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
            applyState(obj, initialState);
            
            obj.history.clear();
        end
        
        function out = stateVar(obj)
            out = obj.stateVarList{1};
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle or BaseFunction
            obj.stateVar.attachDerivFun(derivFun);
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            obj.outputFun = outputFun;
        end
        
        function out = output(obj)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.evaluate(obj.state);
            else
                out = obj.outputFun(obj.state);
            end
        end
        
        % override
        function out = state(obj)
            out = obj.stateVar.value;
        end
        
        % override
        function applyState(obj, stateFeed)
            obj.stateVar.value = stateFeed;
        end
        
        % override
        function out = stateDeriv(obj)
            out = obj.stateVar.flatDeriv;
        end
        
        % implement
        function out = forward(obj, varargin)
            obj.inValues = varargin;
            obj.stateVar.forward(varargin{:});
            out = obj.output;
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
            
            x_dot = linearSystem.stateDeriv;
            
            fprintf('A = [0, 1; -1, -1], B = [0; 1] \n')
            fprintf('linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u) \n')
            fprintf('linearSystem.forward(u_step) where u_step = 1 \n')
            fprintf('linearSystem.output: \n')
            disp(y)
            fprintf('linearSystem.stateDeriv: \n')
            disp(x_dot);
        end
    end
end