classdef DynSystem < SimObject
    properties
        initialStates
        derivFun
        outputFun
    end
    methods
        function obj = DynSystem(initialStates, derivFun, outputFun, name)
            % initialStates = dictionary(var1 = {state1}, var2 = {state2},
            % ...)
            arguments
                initialStates dictionary
                derivFun
                outputFun
                name
            end
            obj = obj@SimObject(-1, name);
            obj.addStateVars(initialStates);
            obj.initialStates = initialStates;

            obj.derivFun = derivFun;
            obj.outputFun = outputFun;
        end
        
        % override
        function out = getOutput(obj)
            out = obj.output_();
        end
    end

    methods(Access=protected)
        % override
        function reset_(obj)
            reset_@SimObject(obj);
            obj.setState(obj.initialStates);
        end

        % may be implemented
        function out = deriv_(obj, varargin)
            % implement this method if needed
            % varargin = {name1, state1, name2, state2, ... inputName1,
            % input1, ...}
            % out: dicionary(name1 = derivState1, name2 = derivState2, ...)
            if isempty(obj.derivFun)
                error('MATLAB:notImplemented', 'Method not implemented')
            end
            out = obj.derivFun(varargin{:});
        end

        % implement
        function out = forward_(obj, varargin)
            states = unpackDict(obj.getStates_());
            derivs = obj.deriv_(states{:}, varargin{:});

            names = obj.stateVars.keys();
            for i = 1:numel(names)
                obj.stateVars(names(i)).setDeriv(derivs(names(i)));
            end

            obj.logger.append('t', obj.time)
            obj.logger.append(states{:}, varargin{:});

            out = obj.output_();
        end

        % may be overridden
        function out = output_(obj)
            if isempty(obj.outputFun)
                out = [];
                return
            end
            states = unpackDict(obj.getStates_());
            out = obj.outputFun(states{:});
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for DynSystem == \n')
            dt = 0.01;
            simClock = SimClock();
            logTimer = Timer(dt);
            logTimer.attachSimClock(simClock);
            logTimer.turnOn();
            
            A = [0, 1;
                -1, -1];
            B = [0; 1];
            derivFun = @(x, u) A*x + B*u;
            model = DynSystem([0; 1], derivFun);
            model.attachSimClock(simClock);
            model.attachLogTimer(logTimer);
            
            tic
            u_step = 1;
            model.propagate(0.01, 10, u_step);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            model.plot();
        end
    end
end