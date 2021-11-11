classdef SimClock < handle
    properties
        time = 0
        timeRes = 1e-6
    end
    methods
        function obj = SimClock(time, timeRes)
            if nargin < 2
                timeRes = 1e-6; % Time resolution
            end
            if nargin < 1
                time = 0; % Current time
            end
            
            obj.time = time;
            obj.timeRes = timeRes;
        end
        
        function reset(obj)
            obj.time = 0;
        end
        
        function applyTime(obj, time)
            obj.time = time;
        end
        
        function applyTimeRes(obj, timeRes)
            obj.timeRes = timeRes;
        end
        
        function elapse(obj, dt)
            obj.time = obj.time + dt;
        end
    end
end