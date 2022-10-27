classdef SimObject < handle
    properties(Constant)
        FLAG_OPERATING = 0;
        ids = Counter(0);
    end
    properties
        id
        name
        flag
        isStatic

        stateVarNames cell
        stateVars cell
        simObjs cell
    end
    properties(Access=protected)
        simClock SimClock
        timer Timer
        logger Logger
        lastOutput
    end
    properties(Dependent)
        numStateVars
        numSimObjs
        time
        output
    end
    methods
        function obj = SimObject(interval, name)
            arguments
                interval = -1
                name = []
            end
            obj.id = SimObject.ids.next();
            if isempty(name)
                obj.name = strcat('simObj_', num2str(obj.id));
            else
                obj.name = name;
            end
            obj.flag = SimObject.FLAG_OPERATING;
            obj.isStatic = true;

            obj.stateVarNames = {};
            obj.stateVars = {};
            obj.simObjs = {};
            obj.timer = Timer(interval);
            obj.logger = Logger();
        end

        function colVars = collectStateVars(obj)
            colVars = cell(1 + obj.numSimObjs, 1);
            colVars{1} = obj.stateVars;

            for i = 1:numel(obj.simObjs)
                colVars{1 + i} = obj.simObjs{i}.collectStateVars();
            end
            colVars = [colVars{:}];
        end

        % dynamic property
        function out = get.numStateVars(obj)
            out = numel(obj.stateVars);
        end

        % dynamic property
        function out = get.numSimObjs(obj)
            out = numel(obj.simObjs);
        end

        function attachSimClock(obj, simClock)
            obj.attachSimClock_(simClock);
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.attachSimClock(simClock);
            end
        end

        function attachLogTimer(obj, logTimer)
            obj.attachLogTimer_(logTimer);
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.attachLogTimer(logTimer);
            end
        end

        function initialize(obj)
            obj.initialize_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.initialize();
            end
        end

        function detachSimClock(obj)
            obj.detachSimClock_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.detachSimClock();
            end
        end

        function detachLogTimer(obj)
            obj.detachLogTimer_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.detachLogTimer();
            end
        end

        function reset(obj)
            obj.reset_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.reset();
            end
        end

        function checkSimClock(obj)
            if isempty(obj.simClock)
                error('MATLAB:noSimClock', 'No SimClock object has been attached.')
            end
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.checkSimClock();
            end
        end

        function setState(obj, varargin)
            for i = 1:numel(varargin)
                obj.stateVars{i}.applyState(varargin{i});
            end
        end

        % property
        function out = get.time(obj)
            if isempty(obj.simClock)
                error('MATLAB:noSimClock', 'No SimClock object has been attached.')
            end
            out = obj.simClock.time;
        end

        function out = state(obj, ind)
            if nargin < 2 || isempty(ind)
                out = obj.getStates_();
                return
            end
            if numel(ind) == 1
                out = obj.stateVars{ind}.state;
                return
            end

            out = cell(1, numel(ind));
            for k = 1:numel(ind)
                out{k} = obj.stateVars{ind(k)}.state;
            end
        end

        function out = deriv(obj, ind)
            if nargin < 2 || isempty(ind)
                out = obj.getDerivs_();
                return
            end
            if numel(ind) == 1
                out = obj.stateVars{ind}.deriv;
                return
            end

            out = cell(1, numel(ind));
            for k = 1:numel(ind)
                out{k} = obj.stateVars{ind(k)}.deriv;
            end
        end

        % dynamic property
        function out = get.output(obj)
            out = obj.getOutput();
        end

        % dynamic property
        function out = getOutput(obj)
            out = obj.lastOutput;
        end

        function out = forward(obj, varargin)
            obj.timer.forward();
            if obj.isStatic
                if obj.timer.isEvent
                    temp = obj.forward_(varargin{:});
                    obj.lastOutput = temp;
                end
            else
                temp = obj.forward_(varargin{:});
                if obj.timer.isEvent
                    obj.lastOutput = temp;
                end
            end
            out = obj.lastOutput;
        end

        function toStop = checkStopCondition(obj, varargin)
            toStopList = cell(1 + obj.numSimObjs, 1);
            toStopList{1} = obj.checkStopCondition_(varargin{:});
            for i = 1:numel(obj.simObjs)
                toStopList{1 + i} = obj.simObjs{i}.checkStopCondition(varargin{:});
            end

            toStop = any(cell2mat(toStopList));
        end

        function out = history(obj, varargin)
            % varargin: variable names
            out = obj.logger.get(varargin{:});
        end

        function report(obj)
            % to be implemented
        end

        function figs = defaultPlot(obj, varKeys)
            if nargin < 2
                varKeys = obj.logger.keys();
                varKeys(find(varKeys == 't', 1)) = [];
            end
            
            try
                timeLog = obj.history('t');
            catch
                error('No key exists for the time variable');
            end

            figs = cell(size(varKeys));
            for i = 1:numel(varKeys)
                varKey = varKeys(i);
                fig = figure();
                figs{i} = fig;
                
                varLog = obj.history(varKey);
                varLog = reshape(varLog, [], size(varLog, ndims(varLog)));

                ind = 1:size(varLog, 1);
                names = cell(numel(ind), 1);
                for k = 1:numel(ind)
                    names{k} = sprintf("%s_%d", varKey, k);
                end

                subplotNum = numel(ind);
                for k = 1:subplotNum
                    subplot(subplotNum, 1, k)
                    hold on
                    plot(timeLog, varLog(ind(k), :), 'DisplayName', "Actual")
                    xlabel("Time (s)")
                    ylabel(names{k})
                    grid on
                    box on
                    legend()
                end
                sgtitle(sprintf("Response of %s in %s", varKey, obj.name))
            end
        end

        function save(obj, filename, dataGroup)
            arguments
                obj
                filename = 'log.h5'
                dataGroup = ''
            end
            dataGroup = dataGroup + '/' + obj.name;
            obj.logger.save(filename, dataGroup)
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.save(filename, dataGroup);
            end
        end

        function load(obj, filename, dataGroup)
            arguments
                obj
                filename = 'log.h5'
                dataGroup = ''
            end
            dataGroup = dataGroup + '/' + obj.name;
            obj.logger.load(filename, dataGroup);
            for i = 1:numel(obj.simObjs)
                obj.simObjs{i}.load(filename, dataGroup);
            end
        end
    end

    methods(Access=protected)
        function addStateVars(obj, names, initialStates)
            if ischar(names) || isstring(names)
                names = {names};
            end
            if isnumeric(initialStates)
                initialStates = {initialStates};
            end

            vars = cell(size(initialStates));
            for i = 1:numel(initialStates)
                vars{i} = StateVariable(initialStates{i});
            end
            obj.stateVarNames = [obj.stateVarNames, names];
            obj.stateVars = [obj.stateVars, vars];
            obj.isStatic = false;
        end

        function addSimObjs(obj, newObjs)
            if isa(newObjs, 'SimObject')
                newObjs = {newObjs};
            end
            
            newSimObjs = cell(size(newObjs));
            numNewSimObjs = 0;

            for i = 1:numel(newObjs)
                newObj = newObjs{i};
                if ~isa(newObj, 'SimObject')
                    continue
                end
                compare = @(x) eq(x, newObj);
                if any(cellfun(compare, obj.simObjs))
                    continue
                end
                numNewSimObjs = numNewSimObjs + 1;
                newSimObjs{numNewSimObjs} = newObj;

                obj.isStatic = obj.isStatic && newObj.isStatic;
            end
            obj.simObjs = [obj.simObjs, newSimObjs(1:numNewSimObjs)];
        end

        function attachSimClock_(obj, simClock)
            obj.simClock = simClock;
            obj.timer.attachSimClock(simClock);
            obj.timer.turnOn();
        end

        function attachLogTimer_(obj, logTimer)
            obj.logger.attachLogTimer(logTimer);
        end

        function initialize_(obj)
            % to be implemented
        end

        function detachSimClock_(obj)
            obj.simClock = [];
            obj.timer.turnOff();
            obj.timer.detachSimClock();
        end

        function detachLogTimer_(obj)
            obj.logger.detachLogTimer();
        end

        function reset_(obj)
            obj.flag = SimObject.FLAG_OPERATING;
            obj.timer.reset();
            obj.logger.clear();
        end

        function states = getStates_(obj)
            states = cell(1, numel(obj.stateVars));
            for i = 1:numel(states)
                states{i} = obj.stateVars{i}.state;
            end
        end

        function derivs = getDerivs_(obj)
            derivs = cell(size(obj.stateVars));
            for i = 1:numel(derivs)
                derivs{i} = obj.stateVars{i}.deriv;
            end
        end

        function out = forward_(obj, varargin)
            % should be implemented
            out = [];
        end

        function toStop = checkStopCondition_(obj, varargin)
            % to be implemented
            toStop = false;
        end
    end
    methods(Static)
        function resetCounter(val)
            arguments
                val = 0;
            end
            SimObject.ids.reset(val);
        end
    end
end


