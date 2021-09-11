classdef DiscTimeInvarDynSystem < DiscDynSystem
    methods
        function obj = DiscTimeInvarDynSystem(initialState, transFun, outputFun)
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x, t) x;
            end
            if nargin < 2
                transFun = [];
            end
            obj = obj@DiscDynSystem(initialState, transFun, outputFun);
            obj.name = "DiscTimeInvarDynSystem";
        end
        
        % to be implemented
        function out = transition(obj, state, varargin)
            % implement this method if needed
            % varargin: {input1, ..., inputM}
            % out: nextState
            fprintf("Attach a transFun or implement the step method! \n")
            out = zeros(size(obj.initialState));
        end
        
        % override
        function step(obj, varargin)
            % varargin: {input1, ..., inputM}
            varsToLog = obj.log(varargin{:});
            obj.logger.append(obj.time, obj.state, varargin{:}, varsToLog{:});
            
            obj.time = obj.time + 1;
            obj.state = obj.transFun(obj.state, varargin{:});
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
            clc
            close all
            
            fprintf("== Test for DiscTimeInvarDynSystem == \n")
            omega = 0.1*2*pi;
            A = [cos(omega), -sin(omega);
                sin(omega), cos(omega)];
            transFun = @(x) A*x;
            
            sys = DiscTimeInvarDynSystem([0; 1], transFun);
            for i = 0:100
                sys.step();
            end
            sys.plot();
        end
    end
end