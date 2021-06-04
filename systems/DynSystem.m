classdef DynSystem < BaseSystem
    properties
        outputFun
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
            
            attachDerivFun(obj, derivFun);
            attachOutputFun(obj, outputFun);
        end
        
        function out = stateVar(obj)
            out = obj.stateVarList{1};
        end
        
        function attachDerivFun(obj, derivFun)
            % derivFun: function_handle
            obj.stateVar.attachDerivFun(derivFun);
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle
            obj.outputFun = outputFun;
        end
        
        function out = output(obj)
            out = obj.outputFun(obj.state);
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
            obj.stateVar.forward(varargin{:});
            out = obj.output;
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