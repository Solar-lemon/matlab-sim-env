classdef FunWrapper < handle
    properties
        value
        funHandle
    end
    methods
        function obj = FunWrapper(funHandle)
            obj.funHandle = funHandle;
        end
        
        function outputVar = forward(obj, varargin)
            % varargin: {Variable, Variable, ..., Variable}
            % outputVar: Variable
            inValues = cell(size(varargin));
            for i = 1:numel(varargin)
                inValues{i} = varargin{i}.value;
            end
            obj.value = obj.funHandle(inValues{:});
            outputVar = Variable(obj.value);
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for FunWrapper == \n')
            fun = @(x, y) x + y;
            funWrapper = FunWrapper(fun);
            x = Variable([1, 2]);
            y = Variable([2, -1]);
            z = funWrapper.forward(x, y);
            
            fprintf('x = Variable([1, 2]), y = Variable([2, -1]) \n')
            fprintf('z = funWrapper.forward(x, y) \n')
            fprintf('z.value: \n')
            disp(z.value)
        end
    end
end