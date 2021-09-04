classdef PolyTrajOptimization < handle
    properties
        % piecewise polynomial w(t)
        % w(t) = w_1(t) (t_0 <= t < t_1)
        % w(t) = w_2(t) (t_1 <= t < t_2)
        % ...
        % w(t) = w_m(t) (t_{m-1} <= t < t_m)
        % basis: {b(t), b(t)^{(1)}, ... b(t)^{(k)}}
        % where b(t) = [t^n; ...; t; 1]
        n
        k
        m
        n_opt
        basis
        t_key
        w_key
        c_opt
    end
    
    methods
        function obj = PolyTrajOptimization(n, k, t_key, w_key)
            % n: the order of the polynomial
            % k: the order of the derivative in the cost function
            % t_key = [t_0, t_1, ..., t_m]
            % w_key = [w_d_0, w_d_1, ..., w_d_m]
            m = numel(t_key) - 1;
            
            basis = cell(k + 1, 1);
            basis{1} = eye(n + 1); % b(t) = [t^n; ...; t; 1]
            b_p = eye(n + 1);
            for l = 1:k
                b_p = Polynomial.polyder(b_p);
                basis{l + 1} = b_p;
            end
            
            obj.n = n;
            obj.k = k;
            obj.m = m;
            obj.n_opt = (n + 1)*m;
            obj.basis = basis;
            obj.t_key = t_key;
            obj.w_key = w_key;
        end
        
        function [c_opt, fval] = optimize(obj)
            % c_opt = [c_1; c_2; ... c_m];
            % continuity constraint
            A_con = cell(1, 1 + obj.k);
            b_con = cell(1, 1 + obj.k);
            for l = 0:obj.k
                [A_con{l + 1}, b_con{l + 1}] = obj.continuityConstraint(l);
            end
            
            % keyframe constraint
            A_key = cell(1, 1);
            b_key = cell(1, 1);
            [A_key{1}, b_key{1}] = obj.keyframeConstraint();
            
            % endpoint constraint
            A_end = cell(1, obj.k);
            b_end = cell(1, obj.k);
            for l = 1:obj.k - 1
                [A_end{l}, b_end{l}] = obj.endpointConstraint(l, [false; false]);
            end
            
            % constraints
            A_eqList = [A_con, A_key, A_end];
            b_eqList = [b_con, b_key, b_end];
            A_eq = vertcat(A_eqList{:});
            b_eq = vertcat(b_eqList{:});
            
            % cost funciton
            H = obj.cost();
            f = zeros(obj.n_opt, 1);
            
            options = optimoptions('quadprog', 'Display', 'off');
            [c_stack, fval] = quadprog(...
                H, f, [], [], A_eq, b_eq, [], [], [], options);
            c_opt = reshape(c_stack, obj.n + 1, []).';
            
            obj.c_opt = c_opt;
        end
        
        function [A_eq, b_eq] = continuityConstraint(obj, l)
            % l: the order of the derivative
            A_eq = zeros(obj.m - 1, obj.n_opt);
            b_eq = zeros(obj.m - 1, 1);
            
            b_l = obj.basis{l + 1};
            
            indexCol = 0;
            for i = 1:obj.m - 1
                t_i = obj.t_key(i + 1);
                b_l_val = Polynomial.polyval(b_l, t_i);
                
                A_eq(i, indexCol + 1:indexCol + 2*(obj.n + 1)) = ...
                    [b_l_val.', -b_l_val.'];
                
                indexCol = indexCol + (obj.n + 1);
            end
        end
        
        function [A_eq, b_eq] = keyframeConstraint(obj)
            A_eq = zeros(obj.m + 1, obj.n_opt);
            b_eq = zeros(obj.m + 1, 1);
            
            b_0 = obj.basis{1};
            
            indexCol = 0;
            for i = 0:obj.m
                t_i = obj.t_key(i + 1);
                w_d_i = obj.w_key(i + 1);
                b_0_val = Polynomial.polyval(b_0, t_i);
                
                A_eq(i + 1, indexCol + 1:indexCol + (obj.n + 1)) =...
                    b_0_val.';
                b_eq(i + 1) = w_d_i;
                
                if i > 0
                    indexCol = indexCol + (obj.n + 1);
                end
            end
        end
        
        function [A_eq, b_eq] = endpointConstraint(obj, l, isFree)
            % l: the order of the derivative
            % isFree: 2x1 boolean vector which specifies each constraint on
            % the initial point and final point.
            if nargin < 3
                isFree = [false; false];
            end
            if nargin < 2
                l = 0;
            end
            t_0 = obj.t_key(1);
            t_m = obj.t_key(end);
            b_l = obj.basis{l + 1};
            b_l_0 = Polynomial.polyval(b_l, t_0);
            b_l_m = Polynomial.polyval(b_l, t_m);
            
            A_eq = zeros(2, obj.n_opt);
            b_eq = zeros(2, 1);
            
            A_eq(1, 1:(obj. n + 1)) = b_l_0.';
            A_eq(2, obj.n_opt - (obj.n + 1) + 1:obj.n_opt) = b_l_m.';
            
            A_eq = A_eq(~isFree, :);
            b_eq = b_eq(~isFree);
        end
        
        function H = cost(obj)
            b_k = obj.basis{end};
            
            G = zeros(obj.n + 1, obj.n + 1, obj.n + 1);
            for i_ = 1:obj.n + 1
                for j_ = 1:obj.n + 1
                    p = conv(b_k(i_, :), b_k(j_, :));
                    G(i_, j_, end - numel(p) + 1:end) = p;
                end
            end
            
            H = cell(1, obj.m);
            for i = 1:obj.m
                t_high = obj.t_key(i + 1);
                t_low = obj.t_key(i);
                
                H_i = zeros(obj.n + 1, obj.n + 1);
                for i_ = 1:obj.n + 1
                    for j_ = 1:obj.n + 1
                        p = squeeze(G(i_, j_, :)).';
                        p = polyint(p);
                        H_i(i_, j_) = polyval(p, t_high) ...
                            - polyval(p, t_low);
                    end
                end
                H{i} = H_i;
            end
            H = blkdiag(H{:});
        end
        
        function plot(obj)
            if isempty(obj.c_opt)
                obj.optimize();
            end
            
            figure();
            hold on
            xlabel('Non-dim time')
            ylabel('Non-dim trajectory')
            grid on
            for i = 1:obj.m
                t_high = obj.t_key(i + 1);
                t_low = obj.t_key(i);
                w_i = obj.c_opt(i, :);
                
                tValues = linspace(t_low, t_high);
                wValues = polyval(w_i, tValues);
                plot(tValues, wValues, '-o', ...
                    'MarkerIndices', [1, size(wValues, 2)], ...
                    'DisplayName', sprintf("w_%d", i))
            end
            legend()
        end
    end
end