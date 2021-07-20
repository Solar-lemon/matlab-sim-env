classdef Variable < handle
    properties
        shape
        value
    end
    properties(Dependent)
        flatValue
    end
    
    methods
        function obj = Variable(value)
            obj.shape = size(value);
            obj.value = value;
        end
        
        function out = numel(obj)
            out = prod(obj.shape);
        end
    end
    % Set and get methods
    methods
        function out = get.flatValue(obj)
            out = reshape(obj.value, [], 1);
        end
        
        function set.flatValue(obj, flatValue)
            assert(numel(flatValue) == numel(obj),...
                "The number of elements does not match.")
            obj.value = reshape(flatValue, obj.shape);
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