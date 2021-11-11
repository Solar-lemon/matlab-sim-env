classdef Timer < handle
    properties
        simClock
        isOperating = false
        eventTimeInterval
        lastEventTime = -inf
        isEvent = false
    end
    methods
        function obj = Timer(eventTimeInterval)
            if nargin < 1 || isempty(eventTimeInterval)
                eventTimeInterval = 0;
            end
            
            obj.eventTimeInterval = eventTimeInterval;
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end
        
        function reset(obj)
            obj.isOperating = false;
            obj.lastEventTime = -inf;
            obj.isEvent = false;
        end
        
        function turnOn(obj, eventTimeInterval)
            if nargin > 1
                obj.eventTimeInterval = eventTimeInterval;
            end
            assert(~isnan(obj.eventTimeInterval),...
                "Set eventTimeInterval first before turning on the timer.")
            
            obj.isOperating = true;
            obj.lastEventTime = obj.simClock.time;
            obj.isEvent = true;
        end
        
        function turnOff(obj)
            obj.isOperating = false;
            obj.lastEventTime = -inf;
            obj.isEvent = false;
        end
        
        function forward(obj)
            if abs(obj.simClock.time - obj.lastEventTime) <= obj.simClock.timeRes
                return
            end
            
            if obj.isOperating
                elapsedTime = obj.simClock.time - obj.lastEventTime;
                if elapsedTime >= (obj.eventTimeInterval - obj.simClock.timeRes)
                    obj.isEvent = true;
                    obj.lastEventTime = obj.simClock.time;
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
            
            dt = 0.01;
            timeRes = 0.0001*dt;
            
            simClock = SimClock(0, timeRes);
            
            eventTimeInterval = 0.1;
            timer = Timer(eventTimeInterval);
            timer.attachSimClock(simClock);
            timer.turnOn();
            
            fprintf('Initial time: 0.0[s] \n')
            fprintf('Event time interval: %.2f[s] \n', eventTimeInterval)
            fprintf('Sampling time interval: %.2f[s] \n\n', dt)
            for i = 1:100
                timer.forward();
                isEvent = timer.isEvent;
                if isEvent
                    fprintf('Event occured at time = %.1f[s] \n', simClock.time)
                end
                simClock.elapse(dt);
            end
        end
    end
end