classdef Timer < handle
    properties
        simClock
        isOperating = false
        eventTimeInterval
        lastEventTime
        isEvent
    end
    methods
        function obj = Timer(eventTimeInterval)
            if nargin < 1 || isempty(eventTimeInterval)
                eventTimeInterval = nan;
            end
            
            obj.eventTimeInterval = eventTimeInterval;
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end
        
        function turnOn(obj)
            assert(~isnan(obj.eventTimeInterval),...
                "Set eventTimeInterval first before turning on the timer.")
            
            obj.isOperating = true;
            obj.lastEventTime = obj.simClock.time;
            obj.isEvent = true;
        end
        
        function turnOff(obj)
            obj.isOperating = false;
            obj.lastEventTime = [];
            obj.isEvent = [];
        end
        
        function forward(obj)
            if abs(obj.simClock.time - obj.lastEventTime) <= obj.simClock.timeResolution
                return
            end
            
            if obj.isOperating
                elapsedTime = obj.simClock.time - obj.lastEventTime;
                if elapsedTime >= (obj.eventTimeInterval - obj.simClock.timeResolution)
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
            timeResolution = 0.0001*dt;
            
            simClock = Clock(0, timeResolution);
            
            eventTimeInterval = 0.1;
            timer = Timer(eventTimeInterval);
            timer.attachSimClock(simClock);
            timer.turnOn();
            
            fprintf('Initial time: 0.0[s] \n')
            fprintf('Event time interval: %.2f[s] \n', eventTimeInterval)
            fprintf('Sampling time interval: %.2f[s] \n\n', dt)
            for i = 1:100
                timer.forward();
                isEvent = timer.checkEvent();
                if isEvent
                    fprintf('Event occured at time = %.1f[s] \n', simClock.time)
                end
                simClock.elapse(dt);
            end
        end
    end
end