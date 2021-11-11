classdef ZeroOrderHold < SimObject
    properties
        funObject
        fun
        timeInterval
        timer
        output
    end
    methods
        function obj = ZeroOrderHold(fun, timeInterval)
            obj = obj@SimObject();
            if isa(fun, 'SimObject')
                obj.funObject = fun;
                obj.fun = @fun.forward;
            elseif isa(fun, 'BaseFunction')
                obj.fun = @fun.forward;
            else
                obj.fun = fun;
            end
            obj.timeInterval = timeInterval;
            obj.timer = Timer(timeInterval);
        end
        
        % override
        function attachSimClock(obj, simClock)
            attachSimClock@SimObject(obj, simClock);
            if ~isempty(obj.funObject)
                obj.funObject.attachSimClock(simClock);
            end
            obj.timer.attachSimClock(simClock);
            obj.timer.turnOn();
        end
        
        % override
        function attachLogTimer(obj, logTimer)
            attachLogTimer@SimObject(obj, logTimer);
            if ~isempty(obj.funObject)
                obj.funObject.attachLogTimer(logTimer);
            end
        end
        
        % override
        function reset(obj)
            reset@SimObject(obj);
            if ~isempty(obj.funObject)
                obj.funObject.reset();
            end
            obj.timer.reset();
        end
        
        % implement
        function out = forward(obj, varargin)
            assert(~isempty(obj.simClock),...
                "[ZeroOrderHold] Attach a simClock first!")
            obj.timer.forward();
            if obj.timer.isEvent
                obj.output = obj.fun(varargin{:});
            end
            out = obj.output;
        end
    end
end