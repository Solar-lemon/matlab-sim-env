classdef Variable < handle
    properties
        value
        shape
        correctionFun
    end
    properties(Dependent)
        flatValue
    end
    
    methods
        function obj = Variable(value)
            obj.value = value;
            obj.shape = size(value);
        end
        
        % implement
        function out = numel(obj)
            out = prod(obj.shape);
        end
        
        function attachCorrectionFun(obj, correctionFun)
            % correctionFun is a function_handle
            obj.correctionFun = correctionFun;
        end
    end
    % Set and get methods
    methods
        function setValue(obj, value)
            if ~isempty(obj.correctionFun)
                value = obj.correctionFun(value);
            end
            obj.value = value;
        end
        
        function setFlatValue(obj, flatValue)
            assert(numel(flatValue) == numel(obj),...
                "The number of elements does not match.")
            setValue(obj, reshape(flatValue, obj.shape));
        end
        
        function out = get.flatValue(obj)
            out = reshape(obj.value, [], 1);
        end
        
        function set.flatValue(obj, flatValue)
            setFlatValue(obj, flatValue);
        end
    end
    methods(Static)
        function test()
            clc
            close all
            
            rng(2021)
            variable = Variable(rand(2, 3));
            fprintf('variable.shape: \n')
            disp(variable.shape)
            fprintf('variable.value: \n')
            disp(variable.value)
            fprintf('variable.flatValue: \n')
            disp(variable.flatValue)
            fprintf('variable.flatValue = [0.5; 0.2; 0.4; 0.4; 0.3; 0.1] \n')
            variable.flatValue = [0.5; 0.2; 0.4; 0.4; 0.3; 0.1];
            fprintf('variable.value: \n')
            disp(variable.value)
            fprintf('numel(variable): \n')
            disp(numel(variable))
        end
    end
end