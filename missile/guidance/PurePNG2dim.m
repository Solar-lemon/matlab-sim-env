classdef PurePNG2dim < BaseFunction
    properties
        N % guidance gain
    end
    methods
        function obj = PurePNG2dim(N)
            obj.N = N;
        end
        
        % implement
        function a_M = forward(obj, v_M, omega)
            % v_M: speed of the missile
            % omega: LOS rate
            a_M = obj.N*v_M*omega;
        end
    end
end