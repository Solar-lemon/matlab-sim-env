classdef Timer < handle
    properties
        isOperating = false
        eventTimeInterval
        lastEventTime
        isEvent
        timeResolution
    end
    methods
        function obj = Timer(eventTimeInterval)
            if nargin < 1 || isempty(eventTimeInterval)
                eventTimeInterval = nan;
            end
            
            obj.eventTimeInterval = eventTimeInterval;
        end
        
        function turnOn(obj, currentTime, timeResolution)
            assert(~isnan(obj.eventTimeInterval),...
                "Set eventTimeInterval first before turning on the timer.")
            
            obj.isOperating = true;
            obj.lastEventTime = currentTime;
            obj.isEvent = true;
            obj.timeResolution = timeResolution;
        end
        
        function turnOff(obj)
            obj.isOperating = false;
            obj.lastEventTime = [];
            obj.isEvent = [];
            obj.timeResolution = [];
        end
        
        function forward(obj, time)
            if abs(time - obj.lastEventTime) <= obj.timeResolution
                return
            end
            
            if obj.isOperating
                elapsedTime = time - obj.lastEventTime;
                if elapsedTime >= (obj.eventTimeInterval - obj.timeResolution)
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
            fprintf("== Test for Timer ==\n")
            
            eventTimeInterval = 0.1;
            timer = Timer(eventTimeInterval);
            
            dt = 0.01;
            time = 0;
            timeResolution = 0.0001*dt;
            timer.turnOn(time, timeResolution);
            
            fprintf('Initial time: 0.0[s] \n')
            fprintf('Event time interval: %.2f[s] \n', eventTimeInterval)
            fprintf('Sampling time interval: %.2f[s] \n\n', dt)
            for i = 1:100
                timer.forward(time);
                isEvent = timer.checkEvent();
                if isEvent
                    fprintf('Event occured at time = %.1f[s] \n', time)
                end
                time = time + dt;
            end
        end
    end
end