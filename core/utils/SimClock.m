classdef Clock < handle
    properties
        time = 0
        timeResolution = 1e-6
    end
    methods
        function obj = Clock(time, timeResolution)
            if nargin > 1
                obj.time = time;
            end
            if nargin > 2
                obj.timeResolution = timeResolution;
            end
        end
        
        function reset(obj)
            obj.time = 0;
            obj.timeResolution = 1e-6;
        end
        
        function applyTime(obj, time)
            obj.time = time;
        end
        
        function applyTimeResolution(obj, timeResolution)
            obj.timeResolution = timeResolution;
        end
        
        function elapse(obj, dt)
            obj.time = obj.time + dt;
        end
    end
end