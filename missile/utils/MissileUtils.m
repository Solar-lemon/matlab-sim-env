classdef MissileUtils < handle
    methods(Static)
        function d_miss = missDistance(p_M, p_T, searchRange)
            % p_M: position trajectory of the missile
            % p_T: position trajectory of the target
            % (2 x numSample or 3 x numSample)
            if nargin < 3
                searchRange = 1;
            end
            numSample = size(p_M, 2);
            [d_miss, index_c] = min(vecnorm(p_M - p_T, 2, 1));
            
            index_min = max(1, index_c - searchRange);
            index_max = min(numSample, index_c + searchRange);
            for i = index_min:index_max - 1
                p0 = p_M(:, i);
                p1 = p_M(:, i + 1);
                q0 = p_T(:, i);
                q1 = p_T(:, i + 1);
                d_miss = min(d_miss, CommonUtils.distanceTrajSegment(p0, p1, q0, q1));
            end
        end
    end
end