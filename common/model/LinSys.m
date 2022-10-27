classdef LinSys < DynSystem
    properties
        A
        B
        C
    end
    methods
        function obj = LinSys(x_0, A, B, C, name)
            arguments
                x_0
                A
                B = []
                C = []
                name = []
            end
            if isempty(B)
                inputNames = [];
            else
                inputNames = {'u'};
            end
            obj = obj@DynSystem({x_0}, {'x'}, inputNames, [], [], name);

            obj.A = A;
            obj.B = B;
            if isempty(C)
                C = eye(size(A, 1));
            end
            obj.C = C;
        end
    end
    methods(Access=protected)
        % implement
        function out = deriv_(obj, x, u)
            arguments
                obj
                x
                u = []
            end
            if isempty(obj.B) || isempty(u)
                out = {obj.A*x};
            else
                out = {obj.A*x + obj.B*u};
            end
        end
    end
end
