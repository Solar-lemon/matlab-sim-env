classdef PurePNG3dimEngagement < MultipleSystem
    properties
        missile
        target
        kinematics
        purePng
        prevRange = inf
    end
    methods
        function obj = PurePNG3dimEngagement(missileState)
            if nargin < 1
                missileState = [-5E3; -1E3; -5E3; 300; deg2rad(-5); 0];
            end
            obj = obj@MultipleSystem();
            
            obj.missile = Missile3dof(missileState);
            obj.target = StationaryVehicle3dof([0; 0; 0]);
            obj.kinematics = EngKinematics(obj.missile, obj.target);
            obj.purePng = PurePNG3dim(3);
            
            obj.attachDynSystems({obj.missile});
        end
        
        % implement
        function forward(obj)
            R_VL = obj.missile.RLocalToVelocity;
            v_M = obj.missile.vel;
            omega = obj.kinematics.losRate;
            
            [a_l, a_n] = obj.purePng.forward(R_VL, v_M, omega);
            obj.missile.forward([0; a_l; a_n]);
        end
        
        % implement
        function toStop = checkStopCondition(obj)
            toStop = obj.missile.checkStopCondition();
            toStop = toStop || obj.rangeIsIncreasing;
            updateRange(obj);
        end
        
        function out = rangeIsIncreasing(obj)
            range = obj.kinematics.range;
            out = (range > obj.prevRange);
        end
        
        function updateRange(obj)
            obj.prevRange = obj.kinematics.range;
        end
        
        function out = missDistance(obj)
            stateList = obj.missile.history{2};
            missilePosList = stateList(1:3, :);
            targetPos = obj.target.pos;
            out = min(vecnorm(missilePosList - targetPos, 2, 1));
        end
        
        function figs = plot(obj)
            figs = cell(1, 1);
            
            figs{1} = figure();
            title('3-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPos(figs{1});
            
            obj.missile.plot();
        end
    end
end