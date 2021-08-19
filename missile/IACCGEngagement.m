classdef IACCGEngagement < Engagement2dim
    properties
        iaccg
    end
    methods
        function obj = IACCGEngagement(missile, target, gamma_M_f)
            obj = obj@Engagement2dim(missile, target);
            
            gamma_T = target.state(4);
            v_M = missile.speed;
            v_T = target.speed;
            
            K = 300;
            if obj.missile.fovLimit == inf
                sigma_d = deg2rad(30);
            else
                sigma_d = obj.missile.fovLimit - 1e-3;
            end
            N = 3;
            obj.iaccg = DiscreteFunction(...
                IACCG(gamma_M_f, gamma_T, v_M, v_T, K, sigma_d, N), 1/40); % 40 Hz
            
            obj.attachDiscSystems({obj.iaccg});
        end
        
        % implement
        function forward(obj)
            forward@Engagement2dim(obj);
            v_M = obj.missile.state(3);
            gamma_M = obj.missile.state(4);
            lam = obj.kinematics.losAngle;
            omega = obj.kinematics.losRate;
            
            a_M = obj.iaccg.forward(v_M, gamma_M, lam, omega);
            a_M = CommonUtils.sat(a_M, 10*FlatEarthEnv.gravAccel, -10*FlatEarthEnv.gravAccel);
            obj.missile.forward([0; a_M]);
        end
        
        function out = impactAngle(obj)
            stateList = obj.missile.history{2};
            rangeList = obj.historyByVarNames('range');
            [~, index] = min(rangeList);
            out = stateList(4, index);
        end
    end
end