classdef DiscSimulator < handle
    properties
        model
        inValues
    end
    properties(Dependent)
        time
    end
    methods
        function obj = DiscSimulator(model)
            % model: an object of DiscDynSystem class
            obj.model = model;
        end
        
        function [toStop, flag] = step(obj, varargin)
            [toStop, flag] = obj.model.checkStopCondition();
            if toStop
                return
            end
            obj.model.step(varargin{:});
            obj.inValues = varargin;
        end
        
        function [toStop, flag] = propagate(obj, stepNum, varargin)
            measureElapsedTime = true;
            try
                measureElapsedTime = isempty(getCurrentTask());
            catch
            end
            
            if measureElapsedTime
                fprintf("[DiscSimulator] Simulating... \n")
                tic
            end
            for i = 1:stepNum
                [toStop, flag] = obj.model.checkStopCondition();
                if toStop
                    break
                end
                newInputs = obj.processInput(varargin);
                obj.model.step(newInputs{:});
            end
            if measureElapsedTime
                elapsedTime = toc;
                fprintf("[DiscSimulator] Elapsed time: %.2f [s] \n", elapsedTime);
            end
            
            obj.inValues = newInputs;
            obj.model.forward(newInputs{:});
        end
        
        function newInputs = processInput(obj, values)
            newInputs = cell(size(values));
            for i = 1:numel(values)
                if isa(values{i}, 'numeric')
                    newInputs{i} = values{i};
                elseif isa(values{i}, 'function_handle')
                    newInputs{i} = values{i}(obj.time);
                elseif isa(values{i}, 'BaseFunction')
                    newInputs{i} = values{i}.forward(obj.time);
                end
            end
        end
    end
    methods
        function out = get.time(obj)
            out = obj.model.time;
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf("== Test for DiscSimulator == \n")
            omega = 0.1*2*pi;
            A = [cos(omega), -sin(omega);
                sin(omega), cos(omega)];
            B = [0; 1];
            transFun = @(x, u) A*x + B*u;
            
            sys = DiscTimeInvarDynSystem([0; 1], transFun);
            DiscSimulator(sys).propagate(100, @(t) 0.5*sin(0.1*pi*t));
            sys.plot();
        end
    end
end