classdef PurePNG3dim < BaseFunction
    properties
        N % guidance gain
    end
    methods
        function obj = PurePNG3dim(N)
            obj.N = N;
        end
        
        % implement
        function a_M = forward(obj, R_VL, v_M, omega)
            % v_M: velocity of the missile expressed in the local frame
            % , 3x1 vector
            % omega: LOS rate expressed in the local frame, 3x1 vector
            % a_l: lateral acceleration
            % a_n: normal acceleration
            accel_L = obj.N * cross(omega, v_M);
            accel_V = R_VL*accel_L;
            
            a_l = accel_V(2);
            a_n = accel_V(3);
            a_M = [0; a_l; a_n];
        end
    end
end