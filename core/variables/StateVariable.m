classdef StateVariable < Variable
    properties
        derivFun
        deriv
    end
    properties
        flatDeriv
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
    end
    % Set and get methods
    methods
        function out = get.flatDeriv(obj)
            out = reshape(obj.deriv, [], 1);
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
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