classdef BaseFunction < handle
    properties
        fun
    end
    methods
        function obj = BaseFunction(fun)
            if nargin < 1
                fun = [];
            end
            obj.fun = fun;
        end
        
        % to be implemented
        function out = forward(obj, varargin)
            assert(~isempty(obj.fun),...
                "Define fun property or implement the forward method")
            out = obj.fun(varargin{:});
        end
    end
end