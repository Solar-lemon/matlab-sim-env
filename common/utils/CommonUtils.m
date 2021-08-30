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
        
        function out = distanceTrajSegment(p0, p1, q0, q1)
            % p0: the initial point of trajectory segment 1
            % p1: the final point of trajectory segment 1
            % q0: the initial point of trajectory segment 2
            % q1: the final point of trajectory segment 2
            function [f, g] = sqDistanceFun(t)
                p = p0 + t*(p1 - p0);
                q = q0 + t*(q1 - q0);
                f = sum((p - q).^2);
                if nargout > 1
                    g = 2*(p - q).'*((p1 - p0) - (q1 - q0));
                end
            end
            % 0 <= t <= 1 (trajectory segments)
            options = optimoptions('fmincon', 'Display', 'none', ...
                'Algorithm', 'sqp', 'SpecifyObjectiveGradient', true);
            d_sq = fmincon(@sqDistanceFun, 0.5, [], [], [], [], 0, 1, [], options);
            out = sqrt(d_sq);
        end
    end
end