classdef DynSystem < SimObject
    properties
        initialStates
        stateNames
        inputNames
        derivFun
        outputFun
    end
    methods
        function obj = DynSystem(initialStates, stateNames, inputNames, derivFun, outputFun, name)
            arguments
                initialStates
                stateNames
                inputNames
                derivFun = []
                outputFun = []
                name = []
            end
            if ischar(stateNames) || isstring(stateNames)
                stateNames = {stateNames};
            end
            if ischar(inputNames) || isstring(inputNames)
                inputNames = {inputNames};
            end

            obj = obj@SimObject(-1, name);

            obj.initialStates = initialStates;
            obj.stateNames = stateNames;
            obj.inputNames = inputNames;

            obj.derivFun = derivFun;
            obj.outputFun = outputFun;

            obj.addStateVars(stateNames, initialStates);
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
            obj.setState(obj.initialStates{:});
        end

        % may be implemented
        function out = deriv_(obj, varargin)
            % implement this method if needed
            % varargin = {state1, state2, ..., input1, ...}
            % out: {derivState1, derivState2, ...}
            if isempty(obj.derivFun)
                error('MATLAB:notImplemented', 'Method not implemented')
            end
            out = obj.derivFun(varargin{:});
        end

        % implement
        function out = forward_(obj, varargin)
            states = obj.getStates_();
            derivs = obj.deriv_(states{:}, varargin{:});
            
            for i = 1:numel(states)
                obj.stateVars{i}.setDeriv(derivs{i});
            end

            if obj.logger.isEvent
                obj.logger.append({'t'}, {obj.time});
                obj.logger.append(obj.stateNames, states);
                obj.logger.append(obj.inputNames, varargin);
            end
            
            out = obj.output_();
        end

        % may be overridden
        function out = output_(obj)
            if isempty(obj.outputFun)
                out = [];
                return
            end
            states = obj.getStates_();
            out = obj.outputFun(states{:});
        end
    end
end