classdef SimObject < handle
    properties(Constant)
        FLAG_OPERATING = 0;
    end
    properties
        id
        name
        flag = SimObject.FLAG_OPERATING;
        isStatic = true;
        stateVars dictionary = dictionary(string([]), StateVariable([]));

        simObjs List = List();
    end
    properties(Access=protected)
        simClock SimClock
        timer Timer
        logger Logger = Logger();
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
            obj.timer = Timer(interval);
        end

        function delete(obj)
            obj.incrementCount(-1);
        end

        function collectedVars = collectStateVars(obj)
            collectedVars = List();

            vars = obj.stateVars.values();
            for i = 1:numel(vars)
                collectedVars.append(vars(i));
            end

            for i = 1:numel(obj.simObjs)
                simObj = obj.simObjs.get(i);
                collectedVars.extend(simObj.collectStateVars());
            end
        end

        % dynamic property
        function out = get.numStateVars(obj)
            out = numEntries(obj.stateVars);
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
                obj.simObjs.get(i).attachLogTimer();
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
            d = kwargsToDict(varargin{:});
            names = d.keys();
            states = d.values();

            for i = 1:numel(names)
                obj.stateVars(names{i}).applyState(states{i});
            end
        end

        % property
        function out = get.time(obj)
            if isempty(obj.simClock)
                error('MATLAB:noSimClock', 'No SimClock object has been attached.')
            end
            out = obj.simClock.time;
        end

        function out = state(obj, varargin)
            if numel(varargin) == 1
                out = obj.stateVars(varargin{1}).state;
            elseif numel(varargin) == 0
                out = obj.getStates_();
            else
                out = dictionary(string([]), {});
                for i = 1:numel(varargin)
                    out(varargin{i}) = obj.stateVars(varargin{i}).state;
                end
            end
        end

        function out = deriv(obj, varargin)
            if numel(varargin) == 1
                out = obj.stateVars(varargin{1}).deriv;
            elseif numel(varargin) == 0
                out = obj.getDerivs_();
            else
                out = dictionary(string([]), {});
                for i = 1:numel(varargin)
                    out(varargin{i}) = obj.stateVars(varargin{i}).deriv;
                end
            end
        end

        % property
        function out = get.output(obj)
            out = obj.getOutput();
        end

        function out = getOutput(obj)
            out = obj.lastOutput;
        end

        function out = forward(obj, varargin)
            obj.timer.forward();
            if obj.isStatic
                if obj.timer.isEvent
                    inputs = kwargsToDict(varargin{:});
                    temp = obj.forward_(inputs);
                    obj.lastOutput = temp;
                end
            else
                inputs = kwargsToDict(varargin{:});
                temp = obj.forward_(inputs);
                if obj.timer.isEvent
                    obj.lastOutput = temp;
                end
            end
            out = obj.lastOutput;
        end

        function toStop = checkStopCondition(obj, varargin)
            kwargs = kwargsToDict(varargin{:});
            toStopList = List();
            toStopList.append(obj.checkStopCondition_(kwargs));
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
                varKeys.remove('time');
            end
            
            figs = List();
            timeLog = obj.history('time');
            
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
        function addStateVars(obj, varargin)
            d = kwargsToDict(varargin{:});
            names = d.keys();
            initialStates = d.values();
            
            for i = 1:numel(names)
                obj.stateVars(names{i}) = StateVariable(initialStates{i});
            end
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
            states = dictionary(string([]), {});
            names = obj.stateVars.keys();
            for i = 1:numel(names)
                states(names{i}) = {obj.stateVars(names{i}).state};
            end
        end

        function derivs = getDerivs_(obj)
            derivs = dictionary(string([]), {});
            names = obj.stateVars.keys();
            for i = 1:numel(names)
                derivs(names{i}) = {obj.stateVars(names{i}).deriv};
            end
        end

        function out = forward_(obj, inputs)
            % should be implemented
            arguments
                obj
                inputs dictionary
            end
            out = [];
        end

        function toStop = checkStopCondition_(obj, inputs)
            % to be implemented
            arguments
                obj
                inputs dictionary
            end
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


