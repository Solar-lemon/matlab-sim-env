classdef SimObject < handle
    properties(Constant)
        FLAG_OPERATING = 0;
    end
    properties
        id
        name
        flag
        isStatic

        stateVarNames List
        stateVars List
        simObjs List
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
            obj.id = obj.incrementCount(1);
            if isempty(name)
                obj.name = strcat('simObj_', num2str(obj.id));
            else
                obj.name = name;
            end
            obj.flag = SimObject.FLAG_OPERATING;
            obj.isStatic = true;

            obj.stateVarNames = List();
            obj.stateVars = List();
            obj.simObjs = List();
            obj.timer = Timer(interval);
            obj.logger = Logger();
        end

        function delete(obj)
            obj.incrementCount(-1);
        end

        function collectedVars = collectStateVars(obj)
            collectedVars = obj.stateVars.copy();

            for i = 1:numel(obj.simObjs)
                simObj = obj.simObjs.get(i);
                collectedVars.extend(simObj.collectStateVars());
            end
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
                obj.simObjs.get(i).attachSimClock(simClock);
            end
        end

        function attachLogTimer(obj, logTimer)
            obj.attachLogTimer_(logTimer);
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).attachLogTimer(logTimer);
            end
        end

        function initialize(obj)
            obj.initialize_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).initialize();
            end
        end

        function detachSimClock(obj)
            obj.detachSimClock_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).detachSimClock();
            end
        end

        function detachLogTimer(obj)
            obj.detachLogTimer_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).detachLogTimer();
            end
        end

        function reset(obj)
            obj.reset_();
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).reset();
            end
        end

        function checkSimClock(obj)
            if isempty(obj.simClock)
                error('MATLAB:noSimClock', 'No SimClock object has been attached.')
            end
            for i = 1:numel(obj.simObjs)
                obj.simObjs.get(i).checkSimClock();
            end
        end

        function setState(obj, varargin)
            for i = 1:numel(varargin)
                obj.stateVars.get(i).applyState(varargin{i});
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
                out = obj.stateVars.get(ind).state;
                return
            end

            out = cell(1, numel(ind));
            for k = 1:numel(ind)
                out{k} = obj.stateVars.get(ind(k)).state;
            end
        end

        function out = deriv(obj, ind)
            if nargin < 2 || isempty(ind)
                out = obj.getDerivs_();
                return
            end
            if numel(ind) == 1
                out = obj.stateVars.get(ind).deriv;
                return
            end

            out = cell(1, numel(ind));
            for k = 1:numel(ind)
                out{k} = obj.stateVars.get(ind(k)).deriv;
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
            toStopList = List();
            toStopList.append(obj.checkStopCondition_(varargin{:}));
            for i = 1:numel(obj.simObjs)
                toStopList.append(obj.simObjs.get(i).checkStopCondition(varargin{:}));
            end

            toStop = any(toStopList.toArray());
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
                varKeys = List(obj.logger.keys());
                varKeys.remove('t');
            end
            
            figs = List();
            timeLog = obj.history('t');
            
            for i = 1:numel(varKeys)
                varKey = varKeys.get(i);
                fig = figure();
                figs.append(fig);
                
                varLog = obj.history(varKey);

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
                obj.simObjs.get(i).save(filename, dataGroup);
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
                obj.simObjs.get(i).load(filename, dataGroup);
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
            obj.stateVarNames.extend(names);
            obj.stateVars.extend(vars);
            obj.isStatic = false;
        end

        function addSimObjs(obj, newObjs)
            if isa(newObjs, 'SimObject')
                newObjs = {newObjs};
            end

            for i = 1:numel(newObjs)
                newObj = newObjs{i};
                if ~isa(newObj, 'SimObject')
                    continue
                end
                if obj.simObjs.contains(newObj)
                    continue
                end
                obj.simObjs.append(newObj);
                obj.isStatic = obj.isStatic && newObj.isStatic;
            end
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
            states = cell(numel(obj.stateVars), 1);
            for i = 1:numel(states)
                states{i} = obj.stateVars.get(i).state;
            end
        end

        function derivs = getDerivs_(obj)
            derivs = cell(size(obj.stateVars));
            for i = 1:numel(derivs)
                derivs{i} = obj.stateVars.get(i).deriv;
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
    
    methods(Static, Access=private)
        function out = incrementCount(value)
            persistent count
            if isempty(count)
                count = 0;
            end
            count = count + value;
            out = count;
        end
    end
end


