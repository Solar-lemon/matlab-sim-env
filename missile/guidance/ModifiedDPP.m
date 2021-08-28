classdef ModifiedDPP < BaseFunction
    properties
        K = 1.0
    end
    methods
        function obj = ModifiedDPP(K)
            obj.K = K;
        end
        
        % implement
        function a_M = forward(obj, v_M, omega, sigma, sigma_d)
            % v_M: speed of the missile
            % omega: LOS rate
            % sigma: look angle
            % sigma_d: desired look angle
            if nargin < 5 || isempty(sigma_d)
                sigma_d = 0;
            end
            a_M = v_M*(omega + obj.K*(sigma_d - sigma));
        end
    end
end