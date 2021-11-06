classdef SimObject < handle
    properties(Constant)
        FLAG_OPERATING = 0;
    end
    properties
        flag = SimObject.FLAG_OPERATING;
        simClock
        logTimer
        logger
    end
    properties(Dependent)
        time
    end
    methods
        function obj = SimObject()
            obj.logger = Logger();
        end
        
        function attachSimClock(obj, simClock)
            obj.simClock = simClock;
        end
        
        function attachLogTimer(obj, logTimer)
            obj.logTimer = logTimer;
        end
        
        function detachSimClock(obj)
            obj.simClock = [];
        end
        
        function detachLogTimer(obj)
            obj.logTimer = [];
        end
        
        function reset(obj)
            obj.flag = SimObject.FLAG_OPERATING;
            obj.logger.clear();
        end
        
        % property
        function out = get.time(obj)
            assert(~isempty(obj.simClock),...
                "[SimObject] Attach a simClock first!")
            out = obj.simClock.time;
        end
        
        % to be implemented
        function forward(obj)
            
        end
        
        % to be implemented
        function [toStop, flag] = checkStopCondition(obj)
            toStop = false;
            flag = obj.flag;
        end
    end
end
        
        
        