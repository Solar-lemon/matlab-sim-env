classdef SimClock < handle
    properties
        time
        timeRes
        dt
        majorTimeStep
    end
    methods
        function obj = SimClock(time, timeRes)
            arguments
                time = 0 % Current time
                timeRes = 1e-6 % Time resolution
            end
            
            obj.time = time;
            obj.timeRes = timeRes;
            obj.majorTimeStep = true;
        end
        
        function reset(obj)
            obj.time = 0;
            obj.dt = [];
        end
        
        function applyTime(obj, time)
            obj.time = time;
        end
        
        function setTimeRes(obj, timeRes)
            obj.timeRes = timeRes;
        end
        
        function setTimeInterval(obj, dt)
            obj.dt = dt;
        end

        function elapse(obj, dt)
            obj.time = obj.time + dt;
        end
    end
end