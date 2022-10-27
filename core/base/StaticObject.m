classdef StaticObject < SimObject
    properties
        evalFun
    end
    methods
        function obj = StaticObject(evalFun, interval, name)
            arguments
                evalFun
                interval = -1
                name = []
            end
            obj = obj@SimObject(interval, name);
            obj.evalFun = evalFun;
        end
    end
    methods(Access=protected)
        function out = forward_(obj, varargin)
            out = obj.evalFun(varargin{:});
        end
    end
end