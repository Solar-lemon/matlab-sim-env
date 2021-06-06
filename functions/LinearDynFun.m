classdef LinearDynFun < BaseFunction
    properties
        A
        B
    end
    methods
        function obj = LinearDynFun(A, B)
            obj.A = A;
            obj.B = B;
        end
        
        % implement
        function out = evaluate(obj, x, u)
            out = obj.A*x + obj.B*u;
        end
    end
    methods(Static)
        function test()
            fprintf('== Test for LinearDynFun class == \n')
            omega = 1;
            zeta  = 0.1;
            A = [0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            x = [0; 1];
            u = 1;
            myFun = LinearDynFun(A, B);
            value = myFun.evaluate(x, u);
            
            fprintf('x = [0; 1]. u = 1 \n')
            fprintf('A: \n')
            disp(A)
            fprintf('B: \n')
            disp(B)
            fprintf('value = myFun.evaluate(x, u); \n')
            fprintf('value: \n')
            disp(value)
        end
    end
end