classdef MinMaxNormalizer < handle
    properties
        maxValue
        minValue
    end
    methods
        function obj = MinMaxNormalizer(minValue, maxValue)
            obj.minValue = minValue;
            obj.maxValue = maxValue;
        end
        
        function normalized = normalize(obj, values)
            % values: d x n
            % d: the dimension of the data, n: the number of the data
            normalized = (values - obj.minValue)./(obj.maxValue - obj.minValue + eps);
        end
        
        function values = denormalize(obj, normalized)
            % normalized: d x n
            % d: the dimension of the normalized data
            % n: the number of the normalized data
            values = normalized.*(obj.maxValue - obj.minValue + eps) + obj.minValue;
        end
    end
    
    methods(Static)
        function obj = normalizer(values)
            % values: d x n
            % d: the dimension of the data, n: the number of the data
            maxValue = max(values, [], 2);
            minValue = min(values, [], 2);
            obj = MinMaxNormalizer(minValue, maxValue);
        end
        
        function test()
            clc
            
            fprintf("== Test for MinMaxNormalizer ==\n")
            maxValue = [4, 10];
            minValue = [-4, -10];
            
            x = [...
                1, 5;
                -1, 4;
                1, -4;
                1, -5];
            normalizer = MinMaxNormalizer(minValue, maxValue);
            x_n = normalizer.normalize(x);
            
            fprintf("maxValue = [4, 10]\n")
            fprintf("minValue = [-4, -10]\n")
            fprintf("The original data: \n")
            disp(x)
            fprintf("The normalized data: \n")
            disp(x_n)
        end
    end
end