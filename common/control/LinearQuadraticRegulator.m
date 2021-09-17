classdef LinearQuadraticRegulator < BaseFunction
    properties
        K
    end
    methods
        function obj = LinearQuadraticRegulator(K)
            obj.K = K;
        end
        
        % implement
        function out = forward(obj, x, x_r)
            if nargin < 3 || isempty(x_r)
                x_r = zeros(size(x));
            end
            out = -obj.K*(x - x_r);
        end
    end
    
    methods(Static)
        function K = gain(A, B, Q, R)
            K = lqr(A, B, Q, R);
        end
    end
end