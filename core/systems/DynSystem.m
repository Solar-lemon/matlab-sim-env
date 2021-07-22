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
        
        % override
        function out = forward(obj, varargin)
            % derivFun: function_handle or BaseFunction
            % derivFun(state, input1, ..., inputM)
            obj.stateVar.forward(varargin{:});
            obj.logger.forward(obj.state, varargin{:});
            if nargout > 0
                out = obj.output;
            end
        end
        
        % override
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.state);
            else
                out = obj.outputFun(obj.state);
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