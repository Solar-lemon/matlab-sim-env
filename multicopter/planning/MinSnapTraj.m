classdef MinSnapTraj < BaseFunction
    properties
        t_key
        sigma_key
        
        t_offset
        t_scale
        sigma_offset
        sigma_scale
        
        c_sigma_0 % coefficients for the 0-th derivative of sigma
        c_sigma_1 % coefficients for the 1-th derivative of sigma
        c_sigma_2 % coefficients for the 2-nd derivative of sigma
        c_sigma_3 % coefficients for the 3-rd derivative of sigma
    end
    methods
        function obj = MinSnapTraj(t_key, sigma_key, c_sigma)
            % t_key = [t_0, t_1, ..., t_m], keytimes
            % sigma_key = [sigma_0, sigma_1, ..., sigma_m], keyframes
            % where sigma = [x; y; z; psi]
            % c_sigma = {c_x; c_y; c_z; c_psi}
            % where
            % c_x = [c_x_1; c_x_2; ..., c_x_m]
            % c_y = [c_y_1; c_y_2; ..., c_y_m]
            % c_z = [c_z_1; c_z_2; ..., c_z_m]
            % c_psi = [c_psi_1; c_psi_2; ..., c_psi_m]
            obj.t_key = t_key;
            obj.sigma_key = sigma_key;
            
            obj.t_offset = t_key(1);
            obj.t_scale = t_key(end) - t_key(1);
            obj.sigma_offset = min(sigma_key, [], 2);
            obj.sigma_scale = ...
                max(sigma_key, [], 2) - min(sigma_key, [], 2) + eps(1);
            
            obj.c_sigma_0 = c_sigma;
            obj.c_sigma_1 = cell(size(c_sigma));
            obj.c_sigma_2 = cell(size(c_sigma));
            obj.c_sigma_3 = cell(size(c_sigma));
            for j = 1:4
                c_j_0 = c_sigma{j};
                c_j_1 = Polynomial.polyder(c_j_0);
                c_j_2 = Polynomial.polyder(c_j_1);
                c_j_3 = Polynomial.polyder(c_j_2);
                
                obj.c_sigma_1{j} = c_j_1;
                obj.c_sigma_2{j} = c_j_2;
                obj.c_sigma_3{j} = c_j_3;
            end
        end
        
        function out = forward(obj, time)
            m = numel(obj.t_key) - 1;
            t_0 = obj.t_key(1);
            t_m = obj.t_key(end);
            
            if time < t_0
                time = t_0;
            end
            if time > t_m
                time = t_m;
            end
            
            ind = find(obj.t_key > time, 1, 'first') - 1;
            if isempty(ind) || (ind > m)
                ind = m;
            end
            tNorm = (time - obj.t_offset)/obj.t_scale;
            sigmaNorm_0 = zeros(4, 1);
            sigmaNorm_1 = zeros(4, 1);
            sigmaNorm_2 = zeros(4, 1);
            sigmaNorm_3 = zeros(4, 1);
            for j = 1:4
                c_j_0 = obj.c_sigma_0{j};
                c_j_1 = obj.c_sigma_1{j};
                c_j_2 = obj.c_sigma_2{j};
                c_j_3 = obj.c_sigma_3{j};
                
                c_ij_0 = c_j_0(ind, :);
                c_ij_1 = c_j_1(ind, :);
                c_ij_2 = c_j_2(ind, :);
                c_ij_3 = c_j_3(ind, :);
                
                sigmaNorm_0(j) = polyval(c_ij_0, tNorm);
                sigmaNorm_1(j) = polyval(c_ij_1, tNorm);
                sigmaNorm_2(j) = polyval(c_ij_2, tNorm);
                sigmaNorm_3(j) = polyval(c_ij_3, tNorm);
            end
            sigma = sigmaNorm_0.*obj.sigma_scale + obj.sigma_offset;
            sigma_dot = sigmaNorm_1.*obj.sigma_scale*(1/obj.t_scale);
            sigma_2dot = sigmaNorm_2.*obj.sigma_scale*(1/obj.t_scale)^2;
            sigma_3dot = sigmaNorm_3.*obj.sigma_scale*(1/obj.t_scale)^3;
            
            out = DerivVariable(sigma, sigma_dot, sigma_2dot, sigma_3dot);
        end
        
        function var_p = posTrajectory(obj, time)
            var_sigma = obj.forward(time);
            var_p = var_sigma.get(1:3);
        end
        
        function var_psi = headTrajectory(obj, time)
            var_sigma = obj.forward(time);
            temp = var_sigma.get(4);
            var_psi = DerivVariable(temp.deriv(0), temp.deriv(1));
        end
        
        function figs = plot(obj, figs)
            if nargin < 2
                figs = cell(2, 1);
                for i = 1:numel(figs)
                    figs{i} = figure();
                end
            end
            
            % 3-dim trajectory plot
            figure(figs{1});
            hold on
            xlabel('x [m]')
            ylabel('y [m]')
            zlabel('z [m]')
            view([-45, 30])
            daspect([1 1 1])
            grid on
            legend('Autoupdate', 'on')
            
            % trajectory for each component
            figure(figs{2});
            ylabelList = {'x [m]', 'y [m]', 'z [m]', 'psi [deg]'};
            for k = 1:4
                subplot(4, 1, k)
                hold on
                xlabel('time [s]')
                ylabel(ylabelList{k});
                grid on
            end
            
            m = numel(obj.t_key) - 1;
            for i = 1:m
                t_high = obj.t_key(i + 1);
                t_low = obj.t_key(i);
                
                timeList = linspace(t_low, t_high, 20);
                sigmaList = zeros(4, numel(timeList));
                for j = 1:numel(timeList)
                    var_sigma = obj.forward(timeList(j));
                    sigmaList(:, j) = var_sigma.deriv(0);
                end
                
                figure(figs{1})
                hold on
                plot3(sigmaList(1, :), sigmaList(2, :), sigmaList(3, :),...
                    '-o', 'MarkerIndices', [1, size(sigmaList, 2)],...
                    'DisplayName', sprintf("sigma_%d", i))
                
                sigmaList(4, :) = rad2deg(sigmaList(4, :));
                figure(figs{2})
                for k = 1:4
                    subplot(4, 1, k)
                    hold on
                    plot(timeList, sigmaList(k, :), '-o',...
                        'MarkerIndices', [1, size(sigmaList, 2)],...
                        'HandleVisibility', 'off')
                end
            end
        end 
    end
end