classdef Timer < handle
    properties
        isOperating = false
        eventTimeInterval
        lastEventTime
        isEvent = true
    end
    methods
        function obj = Timer(eventTimeInterval)
            if nargin < 1 || isempty(eventTimeInterval)
                eventTimeInterval = nan;
            end
            
            obj.eventTimeInterval = eventTimeInterval;
            obj.lastEventTime = 0;
        end
        
        function turnOn(obj, withInitialEvent)
            if nargin < 2 || isempty(withInitialEvent)
                withInitialEvent = false;
            end
            assert(~isnan(obj.eventTimeInterval), "Set the eventTimeInterval first before turning on the timer.")
            
            obj.isOperating = true;
            if withInitialEvent
                obj.lastEventTime = -inf;
            end
        end
        
        function turnOff(obj)
            obj.isOperating = false;
        end
        
        function forward(obj, time)
            if abs(time - obj.lastEventTime) <= 2*eps
                return
            end
            if obj.isOperating
                elapsedTime = time - obj.lastEventTime;
                if elapsedTime >= obj.eventTimeInterval - 2*eps
                    obj.isEvent = true;
                    obj.lastEventTime = time;
                else
                    obj.isEvent = false;
                end
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
            timer.turnOn();
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