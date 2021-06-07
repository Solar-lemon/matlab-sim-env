classdef StateVariable < Variable
    properties
        derivFun
        deriv
    end
    methods
        function obj = StateVariable(value, derivFun)
            % value: numeric
            % derivFun: function_handle or BaseFunction
            obj = obj@Variable(value);
            if nargin > 1
                attachDerivFun(obj, derivFun);
            end
        end
        
        function attachDerivFun(obj, derivFun)
            obj.derivFun = derivFun;
        end
        
        function forward(obj, varargin)
            if isa(obj.derivFun, 'BaseFunction')
                obj.deriv = obj.derivFun.forward(obj.value, varargin{:});
            else
                obj.deriv = obj.derivFun(obj.value, varargin{:});
            end
        end
        
        function out = flatDeriv(obj)
            out = reshape(obj.deriv, [], 1);
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for StateVariable == \n')
            A = [-1, 1;
                0, -2];
            B = [1; 1];
            derivFun = @(x, u) A*x + B*u;
            x = StateVariable([1; 1], derivFun);
            u = 1;
            
            x.forward(u);
            fprintf('A = [-1, 1; 0, -2], B = [1; 1] \n')
            fprintf('derivFun = @(x, u) A*x + B*u \n')
            fprintf('x = StateVariable([1; 1], derivFun), u = 1 \n')
            fprintf('x.forward(u) \n')
            fprintf('x.deriv: \n')
            disp(x.deriv)
        end
    end
end