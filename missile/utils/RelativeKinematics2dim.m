classdef RelativeKinematics2dim < handle
    properties
        % x = [p_x; p_y; V; gamma]
        x_M
        x_T
        v_M
        v_T
        losVec
        lambda
        omega
    end
    methods
        function obj = RelativeKinematics2dim(x_M, x_T)
            if nargin < 1
                x_M = [];
                x_T = [];
            end
            obj.x_M = x_M;
            obj.x_T = x_T;
        end
        
        function update(obj, x_M, x_T)
            obj.x_M = x_M;
            obj.x_T = x_T;
            obj.v_M = [];
            obj.v_T = [];
            obj.losVec = [];
            obj.lambda = [];
            obj.omega = [];
        end
        
        function [v_M, v_T] = velocity(obj)
            if isempty(obj.v_M)
                V_M = obj.x_M(3, :);
                gamma_M = obj.x_M(4, :);
                obj.v_M = V_M.*[cos(gamma_M); sin(gamma_M)];
            end
            if isempty(obj.v_T)
                V_T = obj.x_T(3, :);
                gamma_T = obj.x_T(4, :);
                obj.v_T = V_T.*[cos(gamma_T); sin(gamma_T)];
            end
            v_M = obj.v_M;
            v_T = obj.v_T;
        end
        
        function r = range(obj)
            % p_M: 2 x n, p_T: 2 x n
            p_M = obj.x_M(1:2, :);
            p_T = obj.x_T(1:2, :);
            r = vecnorm(p_M - p_T, 2, 1);
        end
        
        function out = losVector(obj)
            % p_M: 2 x n, p_T: 2 x n
            if isempty(obj.losVec)
                p_M = obj.x_M(1:2, :);
                p_T = obj.x_T(1:2, :);
                p_r = p_T - p_M;
                obj.losVec = p_r ./ vecnorm(p_r, 2, 1);
            end
            out = obj.losVec;
        end
        
        function lambda = losAngle(obj)
            if isempty(obj.lambda)
                losVec_ = obj.losVector();
                obj.lambda = atan2(losVec_(2, :), losVec_(1, :));
            end
            lambda = obj.lambda;
        end
        
        function sigma = lookAngle(obj)
            lambda_ = obj.losAngle();
            gamma_M = obj.x_M(4, :);
            sigma = gamma_M - lambda_;
        end
        
        function omega = losRate(obj)
            if isempty(obj.omega)
                p_M = obj.x_M(1:2, :);
                p_T = obj.x_T(1:2, :);
                [v_M_, v_T_] = obj.velocity();
                
                p_r = p_T - p_M;
                v_r = v_T_ - v_M_;
                v_r = [v_r; zeros(1, size(v_r, 2))];
                losVec_ = obj.losVector();
                losVec_ = [losVec_; zeros(1, size(losVec_, 2))];
                
                omega_ = cross(losVec_, v_r, 1)/norm(p_r);
                obj.omega = omega_(3, :);
            end
            omega = obj.omega;
        end
        
        function V_c = closingSpeed(obj)
            [v_M_, v_T_] = obj.velocity();
            v_r = v_T_ - v_M_;
            V_c = vecnorm(v_r, 2, 1);
        end
    end
end