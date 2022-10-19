classdef Timer < handle
    properties
        simClock SimClock
        eventTimeInterval

        isOperating logical = false
        isEvent logical = false
    end
    properties(Access=protected)
        lastEventTime = -inf
    end
    methods
        function obj = Timer(eventTimeInterval)
            arguments
                eventTimeInterval = -1
            end
            obj.eventTimeInterval = eventTimeInterval;
        end

        function reset(obj)
            obj.turnOn();
            obj.lastEventTime = -inf;
        end

        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end

        function turnOn(obj, eventTimeInterval)
            if isempty(obj.simClock)
                error('MATLAB:noSimClock', 'No SimClock object has been attached.')
            end
            if nargin > 1
                obj.eventTimeInterval = eventTimeInterval;
            end
            
            obj.isOperating = true;
            obj.isEvent = true;
            obj.lastEventTime = obj.simClock.time;
        end

        function turnOff(obj)
            obj.isOperating = false;
            obj.isEvent = false;
            obj.lastEventTime = -inf;
        end

        function detachSimClock(obj)
            obj.simClock = [];
        end

        function forward(obj)
            if obj.isOperating
                % prevent repetitive calling
                if abs(obj.simClock.time - obj.lastEventTime) <= obj.simClock.timeRes
                    return
                end

                % always raise an event when the event time interval is -1
                if obj.eventTimeInterval == -1
                    obj.isEvent = true;
                    obj.lastEventTime = obj.simClock.time;
                    return
                end

                elapsedTime = obj.simClock.time - obj.lastEventTime;
                if elapsedTime >= (obj.eventTimeInterval - obj.simClock.timeRes)
                    obj.isEvent = true;
                    obj.lastEventTime = obj.simClock.time;
                else
                    obj.isEvent = false;
                end
            end
        end
    end

    methods(Static)
        function test()
            clc
            fprintf("== Test for Timer ==\n")

            dt = 0.01;
            simClock = SimClock();

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