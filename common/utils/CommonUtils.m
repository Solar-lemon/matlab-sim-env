classdef CommonUtils < handle
    methods(Static)
        function vector = sat(vector, lowerLimit, upperLimit)
            if nargin < 2
                vector = Utils.unitSat(vector);
                return
            end
            if any(lowerLimit > upperLimit)
                error('Lower limit values should not be larger than upper limit values')
            end
            if length(upperLimit) == 1
                upperLimit = upperLimit*ones(size(vector));
            end
            if length(lowerLimit) == 1
                lowerLimit = lowerLimit*ones(size(vector));
            end
            vector(vector > upperLimit) = upperLimit(vector > upperLimit);
            vector(vector < lowerLimit) = lowerLimit(vector < lowerLimit);
        end
        
        function vector = unitSat(vector)
            vector(vector > 1) = 1;
            vector(vector < -1) = -1;
        end
        
        function angle = wrapToPi(angle)
            angle(angle > pi) = angle(angle > pi) - 2*pi;
            angle(angle < -pi) = angle(angle < -pi) + 2*pi;
        end
    end
end