classdef SignalGenerator < SimObject
    properties
        shapingFun
    end
    methods
        function obj = SignalGenerator(shapingFun)
            obj = obj@SimObject();
            obj.shapingFun = shapingFun;
        end
        
        % implement
        function out = forward(obj)
            out = obj.shapingFun(obj.simClock.time);
        end
    end
end