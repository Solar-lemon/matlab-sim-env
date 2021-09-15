classdef DiscDynSystem < handle
    properties
        time = 0
        initialState
        state
        stateNum
        transFun
        outputFun
        logger
        name = "discDynSystem";
        flag = 0
    end
    properties(Dependent)
        history
    end
    
    methods
        function obj = DiscDynSystem(initialState, transFun, outputFun)
            % initialState: n x 1 array
            % transFun: state transition function
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x, t) x;
            end
            if nargin < 2 || isempty(transFun)
                transFun = @obj.transition;
            end
            obj.initialState = initialState;
            obj.state = initialState;
            obj.stateNum = numel(initialState);
            obj.logger = MatStackedData();
            obj.attachTransFun(transFun);
            obj.attachOutputFun(outputFun);
        end
        
        function reset(obj, initialState)
            if nargin < 2
                initialState = obj.initialState;
            end
            obj.time = 0;
            obj.state = initialState;
            obj.logger.clear();
        end
        
        function attachTransFun(obj, transFun)
            % transFun: function_handle or BaseFunction
            % transFun(state, time, input1, ..., inputM)
            obj.transFun = transFun;
        end
        
        function attachOutputFun(obj, outputFun)
            % outputFun: function_handle or BaseFunction
            % outputFun(state, time)
            obj.outputFun = outputFun;
        end
        
        % to be implemented
        function out = transition(obj, state, time, varargin)
            % implement this method if needed
            % varargin: {input1, ..., inputM}
            % out: nextState
            fprintf("Attach a transFun or implement the step method! \n")
            out = zeros(size(obj.initialState));
        end
        
        % to be implemented
        function varsToLog = log(obj, varargin)
            % implement this method if needed
            % varargin: {input1, ..., inputM}
            varsToLog = {};
        end
        
        function forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            varsToLog = obj.log(varargin{:});
            obj.logger.append(obj.time, obj.state, varargin{:}, varsToLog{:});
        end
        
        function step(obj, varargin)
            % varargin: {input1, ..., inputM}
            obj.forward(varargin{:});
            obj.state = obj.transFun(obj.state, obj.time, varargin{:});
            obj.time = obj.time + 1;
        end
        
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            if isa(obj.outputFun, 'BaseFunction')
                out = obj.outputFun.forward(obj.state, obj.time);
            else
                out = obj.outputFun(obj.state, obj.time);
            end
        end
        
        % to be implemented
        function [toStop, flag] = checkStopCondition(obj)
            % implement this method if needed
            toStop = false;
            
            if nargout > 1
                flag = obj.flag;
            end
        end
    end
    
    methods
        function out = get.history(obj)
            assert(obj.logger.dataNum > 0,...
                "There is no simulation data to load \n")
            out = obj.logger.matValues;
        end
    end
    
    methods
        % to be implemented
        function report(obj)
            
        end
        
        function figs = plot(obj)
            figNum = numel(obj.history) - 1;
            figs = cell(1, figNum);
            for i = 1:figNum
                figs{i} = figure();
            end
            
            timeList = obj.history{1};
            for i = 1:figNum
                figure(figs{i});
                varList = obj.history{i + 1};
                
                if i == 1
                    figs{i}.Name = "State";
                    sgtitle("State")
                    varLabel = "x";
                else
                    figs{i}.Name = sprintf("Control input %d", i - 1);
                    sgtitle(sprintf("Control input %d", i - 1))
                    varLabel = sprintf("u%d", i - 1);
                end
                subplotNum = size(varList, 1);
                for k = 1:subplotNum
                    subplot(subplotNum, 1, k)
                    hold on
                    stairs(timeList, varList(k, :),...
                        'DisplayName', sprintf(varLabel + "(%d)", k))
                    xlabel("Time [s]")
                    ylabel(sprintf(varLabel + "(%d)", k))
                    grid on
                    box on
                end
            end
        end
    end
    
    methods
        function save(obj, folder)
            if nargin < 2 || isempty(folder)
                folder = "data/logData/" + obj.name + "/";
            end
            obj.logger.save(folder + "history.mat");
            
            infoFile = matfile(folder + "info.mat", 'Writable', true);
            infoFile.state = obj.state;
        end
        
        function load(obj, folder)
            if nargin < 2 || isempty(folder)
                folder = "data/logData/" + obj.name + "/";
            end
            obj.logger.load(folder + "history.mat");
            
            infoFile = matfile(folder + "info.mat");
            obj.state = infoFile.state;
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for DiscDynSystem == \n")
            omega = 0.1*2*pi;
            A = [cos(omega), -sin(omega);
                sin(omega), cos(omega)];
            transFun = @(x, t) A*x;
            
            sys = DiscDynSystem([0; 1], transFun);
            for i = 0:100
                sys.step();
            end
            sys.plot();
        end
    end
end
            