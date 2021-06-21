classdef Timer < handle
    properties
        eventTimeInterval
        lastEventTime
        isEvent = true
    end
    methods
        function obj = Timer(eventTimeInterval, withInitialEvent)
            if nargin < 2 || isempty(withInitialEvent)
                withInitialEvent = false;
            end
            
            obj.eventTimeInterval = eventTimeInterval;
            if withInitialEvent
                obj.lastEventTime = -inf;
            else
                obj.lastEventTime = 0;
            end
        end
        
        function forward(obj, time)
            elapsedTime = time - obj.lastEventTime;
            if elapsedTime >= obj.eventTimeInterval - eps
                obj.isEvent = true;
                obj.lastEventTime = time;
            else
                obj.isEvent = false;
            end
        end
        
        function isEvent = checkEvent(obj)
            isEvent = obj.isEvent;
        end
    end
    
    methods(Static)
        function test()
            clc
            
            eventTimeInterval = 1;
            
            timer = Timer(eventTimeInterval);
            dt = 0.4;
            
            fprintf('Initial time: 0.0[s] \n')
            fprintf('Event time interval: %.1f[s] \n', eventTimeInterval)
            fprintf('Sampling time interval: %.1f[s] \n', dt)
            
            time = 0;
            for i = 1:5
                timer.forward(time);
                isEvent = timer.checkEvent();
                if isEvent
                    fprintf('Event occured at time = %.1f [s] \n', time)
                end
                time = time + dt;
            end
        end
    end
end