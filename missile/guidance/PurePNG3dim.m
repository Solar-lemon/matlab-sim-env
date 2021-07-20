classdef PurePNG3dim < BaseFunction
    properties
        N % guidance gain
    end
    methods
        function obj = PurePNG3dim(N)
            obj.N = N;
        end
        
        % implement
        function [a_l, a_n] = forward(obj, v_M, omega)
            % v_M: velocity of the missile, 3x1 vector
            % omega: LOS rate, 3x1 vector
            % a_l: lateral acceleration
            % a_n: normal acceleration
            accel = obj.N * cross(omega, v_M);
            
            a_l = accel(2);
            a_n = accel(3);
        end
    end
end