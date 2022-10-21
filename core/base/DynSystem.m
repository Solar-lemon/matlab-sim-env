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
                outputFun = []
                name = []
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
            % kwargs = dictionary(name1, state1, name2, state2, ... inputName1,
            % input1, ...)
            % out: dicionary(name1, derivState1, name2, derivState2, ...)
            if isempty(obj.derivFun)
                error('MATLAB:notImplemented', 'Method not implemented')
            end
            out = obj.derivFun(varargin{:});
        end

        % implement
        function out = forward_(obj, varargin)
            states = dictToKwargs(obj.getStates_());
            inputs = varargin;
            derivs = obj.deriv_(states{:}, inputs{:});

            names = obj.stateVars.keys();
            for i = 1:numel(names)
                obj.stateVars(names(i)).setDeriv(derivs(names(i)));
            end

            obj.logger.append('time', obj.time, states{:}, inputs{:});

            out = obj.output_();
        end

        % may be overridden
        function out = output_(obj)
            if isempty(obj.outputFun)
                out = [];
                return
            end
            states = dictToKwargs(obj.getStates_());
            out = obj.outputFun(states{:});
        end
    end
end