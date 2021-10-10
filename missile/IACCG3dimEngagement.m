classdef IACCG3dimEngagement < Engagement3dim
    properties
        iaccgLat
        iaccgLon
    end
    methods
        function obj = IACCG3dimEngagement(missile, target, impactAngle, sigma_d)
            % impactAngle = [chi; gamma], sigma_d = [simga_lat, simga_lon]
            obj = obj@Engagement3dim(missile, target);
            
            gamma_T = target.state(5);
            chi_T = target.state(6);
            v_T = target.speed;
            v_T_Hor = v_T*cos(gamma_T);
            
            gamma_M = missile.state(5);
            v_M = missile.speed;
            v_M_Hor = v_M*cos(gamma_M);
            
            K = 1.5;
            N = 3;
            obj.iaccgLat = DiscreteFunction(...
                IACCG(impactAngle(1), chi_T, v_M_Hor, v_T_Hor, K, sigma_d(1), N),...
                1/40);
            obj.iaccgLon = DiscreteFunction(...
                IACCG(impactAngle(2), gamma_T, v_M, v_T, K, sigma_d(2), N),...
                1/40);
            
            obj.attachDiscSystems({obj.iaccgLat, obj.iaccgLon});
        end
        
        % implement
        function forward(obj)
            forward@Engagement3dim(obj);
            v_M = obj.missile.speed;
            gamma = obj.missile.state(5);
            sigma = obj.missile.lookAngle();
            lam = obj.kinematics.losAngle;
            omega = obj.kinematics.losRate;
            
            a_Lat = obj.iaccgLat.forward(v_M*cos(gamma), -sigma(1), lam(1), omega(3));
            a_Lon = obj.iaccgLon.forward(v_M, sigma(2), lam(2), omega(2));
            
            obj.missile.forward([0; a_Lat; -a_Lon]);
        end
    end
end