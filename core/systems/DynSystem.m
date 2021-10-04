classdef DynSystem < TimeVaryingDynSystem
    properties
        
    end
    methods
        function obj = DynSystem(initialState, derivFun, outputFun)
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x) x;
            end
            if nargin < 2
                derivFun = [];
            end
            obj = obj@TimeVaryingDynSystem(initialState, derivFun, outputFun);
            obj.name = 'dynSystem';
        end
        
        % to be implemented
        function out = derivative(obj, varargin)
            % implement this method if needed
            % varargin: {state, input1, ..., inputM}
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
        
        % override
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            if isa(obj.derivFun, 'BaseFunction')
                deriv = obj.derivFun.forward(...
                    obj.stateVarList{1}.state, varargin{:});
                obj.stateVarList{1}.forward(deriv);
            else
                deriv = obj.derivFun(...
                    obj.stateVarList{1}.state, varargin{:});
                obj.stateVarList{1}.forward(deriv);
            end
            
            varsToLog = obj.log(varargin{:});
            obj.logger.forward(obj.stateVarList{1}.state, varargin{:}, varsToLog{:});
            
            if nargout > 0
                out = obj.output;
            end
        end
        
        % override
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.stateVarList{1}.state);
            else
                out = obj.outputFun(obj.stateVarList{1}.state);
            end
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for DynSystem == \n')
            A = [0, 1;
                -1, -1];
            B = [0; 1];
            dynSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
            
            tic
            u_step = 1;
            Simulator(dynSystem).propagate(0.01, 10, true, u_step);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            dynSystem.plot();
        end
    end
end