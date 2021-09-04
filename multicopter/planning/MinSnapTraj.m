classdef MinSnapTraj < BaseFunction
    properties
        t_key
        sigma_key
        
        t_offset
        t_scale
        sigma_offset
        sigma_scale
        
        c_x
        c_y
        c_z
        c_psi
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
            
            [obj.c_x, obj.c_y, obj.c_z, obj.c_psi] = c_sigma{:};
        end
        
        function sigma = forward(obj, time)
            m = numel(obj.t_key) - 1;
            t_0 = obj.t_key(1);
            t_m = obj.t_key(end);
            
            time(time < t_0) = t_0;
            time(time > t_m) = t_m;
            
            t_tilde = (time - obj.t_offset)/obj.t_scale;
            sigma_tilde = zeros(4, numel(t_tilde));
            for j = 1:numel(t_tilde)
                ind = find(obj.t_key > time(j), 1, 'first') - 1;
                if isempty(ind) || (ind > m)
                    ind = m;
                end
                x_tilde = polyval(obj.c_x(ind, :), t_tilde(j));
                y_tilde = polyval(obj.c_y(ind, :), t_tilde(j));
                z_tilde = polyval(obj.c_z(ind, :), t_tilde(j));
                psi_tilde = polyval(obj.c_psi(ind, :), t_tilde(j));
                sigma_tilde(:, j) = [x_tilde; y_tilde; z_tilde; psi_tilde];
            end
            sigma = sigma_tilde.*obj.sigma_scale + obj.sigma_offset;
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
                
                timeList = linspace(t_low, t_high);
                sigmaList = obj.forward(timeList);
                
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