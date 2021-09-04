classdef Polynomial < handle
    properties
        
    end
    methods(Static)
        % p: d x n vector
        % where
        % d: the dimension of the polynomial vector p(x)
        % n: the highest order of the polynomial vector p(x)
        % for example, a polynomial vector [x^2, x] can be
        % represented as
        % [1, 0, 0; 0, 1, 0];
        function p_k = polyder(p, k)
            % k: the order of the derivative
            if nargin < 2
                k = 1;
            end
            [d, n] = size(p);
            
            if k >= n
                p_k = zeros(d, 1);
                return
            end
            
            p_k = zeros(d, n - k);
            for i = 1:d
                temp = p(i, :);
                for j = 1:k
                    temp = polyder(temp);
                end
                p_k(i, n - k - numel(temp) + 1:n - k) = temp;
            end
        end
        
        function out = polyval(p, x)
            % x: scalar
            d = size(p, 1);
            out = zeros(d, 1);
            for i = 1:d
                out(i) = polyval(p(i, :), x);
            end
        end
    end
end