classdef LQR < SimObject
    properties
        K
    end
    methods
        function obj = LQR(K, interval, name)
            arguments
                K
                interval = -1
                name = [];
            end
            obj = obj@SimObject(interval, name);
            obj.K = K;
        end
    end
    methods(Access=protected)
        % implement
        function out = forward_(obj, x, r)
            if nargin < 3 || isempty(r)
                r = zeors(size(x));
            end
            out = obj.K*(r - x);
        end
    end
    methods(Static)
        function K = gain(A, B, Q, R)
            K = lqr(A, B, Q, R);
        end
    end
end