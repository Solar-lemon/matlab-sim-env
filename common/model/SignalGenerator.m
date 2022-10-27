classdef SignalGenerator < SimObject
    properties
        shapingFun
    end
    methods
        function obj = SignalGenerator(shapingFun, interval, name)
            arguments
                shapingFun function_handle
                interval = -1;
                name = [];
            end
            obj = obj@SimObject(interval, name);
            obj.shapingFun = shapingFun;
        end
    end
    methods(Access=protected)
        % implementation
        function out = forward_(obj, varargin)
            out = obj.shapingFun(obj.time, varargin{:});
        end
    end
end