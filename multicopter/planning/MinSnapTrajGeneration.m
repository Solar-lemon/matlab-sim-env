classdef MinSnapTrajGeneration < handle
    properties
        % basis: {b(tau), b(tau)^{(1)}, ... b(tau)^{(k)}}
        % where b(tau) = [tau^n; ...; tau; 1]
        n
        k
        m
        t_key
        sigma_key
        
        t_normalizer
        sigma_normalizer
    end
    
    methods
        function obj = MinSnapTrajGeneration(n, k, t_key, sigma_key)
            % n: the order of the polynomial
            if numel(n) == 1
                n = n*ones(4, 1);
            end
            if numel(k) == 1
                k = k*ones(4, 1);
            end
            m = numel(t_key) - 1;
            
            obj.n = n;
            obj.k = k;
            obj.m = m;
            obj.t_key = t_key;
            obj.sigma_key = sigma_key;
            
            obj.t_normalizer = MinMaxNormalizer.normalizer(t_key);
            obj.sigma_normalizer = MinMaxNormalizer.normalizer(sigma_key);
        end
        
        function traj = generateTraj(obj, optimizeTime)
            if nargin < 2
                optimizeTime = false;
            end
            polyTrajOpt = cell(4, 1);
            c_sigma = cell(4, 1);
            
            if optimizeTime
                t_key_ = obj.optimizeTimeSegment();
            else
                t_key_ = obj.t_key;
            end
            
            t_keyNorm = obj.t_normalizer.normalize(t_key_);
            sigma_keyNorm = obj.sigma_normalizer.normalize(obj.sigma_key);
            for j = 1:4
                polyTrajOpt{j} = PolyTrajOptimization(...
                    obj.n(j), obj.k(j), t_keyNorm, sigma_keyNorm(j, :));
                c_sigma{j} = polyTrajOpt{j}.optimize();
            end
            traj = MinSnapTraj(t_key_, obj.sigma_key, c_sigma);
        end
        
        function [t_keyOpt, fval] = optimizeTimeSegment(obj)
            fprintf("[MinSnapTrajGeneration] Time segements will be optimized.. \n")
            % T = [T_1, T_2, ..., T_m];
            % T_1 + T_2 + ... + T_m = 1 (normalized)
            sigma_keyNorm = obj.sigma_normalizer.normalize(obj.sigma_key);
            
            n_ = obj.n;
            k_ = obj.k;
            sigma_d_ = sigma_keyNorm;
            function cost = fun(T)
                % T = [T_1; T_2; ..., T_m]
                t_key_ = MinSnapTrajGeneration.varToKey(0, T.');
                
                polyTrajOpt = cell(4, 1);
                cost = 0;
                for j = 1:4
                    polyTrajOpt{j} = PolyTrajOptimization(...
                        n_(j), k_(j), t_key_, sigma_d_(j, :));
                    [~, cost_j] = polyTrajOpt{j}.optimize();
                    cost = cost + cost_j;
                end
            end
            
            A = -eye(obj.m);
            b = -zeros(obj.m, 1);
            A_eq = ones(1, obj.m);
            b_eq = 1;
            
            Sigma = MinSnapTrajGeneration.keyToVar(sigma_keyNorm);
            temp = vecnorm(Sigma, 2, 1).';
            T_init = temp/sum(temp);
            
            options = optimoptions('fmincon', 'MaxIterations', 20);
            [T, fval] = fmincon(@fun, T_init, A, b, A_eq, b_eq, [], [], [], options);
            T = T.';
            
            t_keyOptNorm = MinSnapTrajGeneration.varToKey(0, T);
            t_keyOpt = obj.t_normalizer.denormalize(t_keyOptNorm);
        end
    end
    
    methods(Static)
        function X = keyToVar(x)
            % key x = [x_0, x_1, ..., x_{m - 1}, x_m]
            % variation X = [X_1, X_2, ..., X_m]
            % where X_1 = x_1 - x_0, ..., X_m = x_m - x_{m - 1}
            m = size(x, 2) - 1;
            X = zeros(size(x, 1), m);
            for i = 1:m
                X(:, i) = x(:, i + 1) - x(:, i);
            end
        end
        
        function x = varToKey(x_0, X)
            % x = [x_0, x_1, ..., x_{m - 1}, x_m]
            % X = [X_1, X_2, ..., X_m]
            % where X_1 = x_1 - x_0, ..., X_m = x_m - x_{m - 1}
            m = size(X, 2);
            x = zeros(size(X, 1), 1 + m);
            x(:, 1) = x_0;
            for i = 1:m
                x(:, i + 1) = x(:, i) + X(:, i);
            end
        end
    end
end