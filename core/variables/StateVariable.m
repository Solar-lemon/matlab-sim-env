classdef StateVariable < Variable
    properties
        useBaseFunction
        derivFun
        deriv
        rk4Buffer
    end
    properties(Dependent)
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
            obj.rk4Buffer = cell(1, 5); % rk4Buffer = {x0, k1, k2, k3, k4}
            obj.rk4Buffer{1} = obj.flatValue;
        end
        
        function attachDerivFun(obj, derivFun)
            obj.useBaseFunction = isa(derivFun, 'BaseFunction');
            obj.derivFun = derivFun;
        end
        
        function forward(obj, varargin)
            if obj.useBaseFunction
                obj.deriv = obj.derivFun.forward(obj.value, varargin{:});
            else
                obj.deriv = obj.derivFun(obj.value, varargin{:});
            end
        end
        
        function rk4Update1(obj, dt)
            obj.rk4Buffer{1} = obj.flatValue; % y0
            obj.rk4Buffer{2} = obj.flatDeriv; % k1
            obj.setFlatValue(...
                obj.rk4Buffer{1} + dt/2*obj.rk4Buffer{2});
            % y = y0 + dt/2*k1
        end
        
        function rk4Update2(obj, dt)
            obj.rk4Buffer{3} = obj.flatDeriv; % k2
            obj.setFlatValue(...
                obj.rk4Buffer{1} + dt/2*obj.rk4Buffer{3});
            % y = y0 + dt/2*k2
        end
        
        function rk4Update3(obj, dt)
            obj.rk4Buffer{4} = obj.flatDeriv; % k3
            obj.setFlatValue(...
                obj.rk4Buffer{1} + dt*obj.rk4Buffer{4});
            % y = y0 + dt*k3
        end
        
        function rk4Update4(obj, dt)
            obj.rk4Buffer{5} = obj.flatDeriv; % k4
            [y0, k1, k2, k3, k4] = obj.rk4Buffer{:};
            y = y0 + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
            
            obj.setFlatValue(y);
            obj.rk4Buffer{1} = y;
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