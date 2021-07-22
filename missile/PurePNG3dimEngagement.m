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
            obj.purePng = DiscreteFunction(PurePNG3dim(3), 1/40); % 40 Hz
            
            obj.attachDynSystems({obj.missile});
            obj.attachDiscSystems({obj.purePng});
        end
        
        % implement
        function forward(obj)
            R_VL = obj.missile.RLocalToVelocity;
            v_M = obj.missile.vel;
            omega = obj.kinematics.losRate;
            r = obj.kinematics.range;
            
            a_M = obj.purePng.forward(R_VL, v_M, omega);
            obj.missile.forward(a_M);
            
            obj.logger.forward(omega, r);
            obj.logger.forwardVarNames('losRate', 'range');
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
            rangeList = obj.historyByVarNames('range');
            out = min(rangeList);
        end
        
        function figs = plot(obj)
            figs = cell(2, 1);
            
            obj.missile.plot();
            
            figs{1} = figure();
            title('3-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPos(figs{1});
            
            temp = obj.historyByVarNames('time', 'losRate');
            [timeList, losRateList] = temp{:};
            losRateList = rad2deg(losRateList);
            
            figs{2} = figure();
            title('LOS rate')
            labelList = {'omega_x', 'omega_y', 'omega_z'};
            for k = 1:3
                subplot(3, 1, k)
                plot(timeList, losRateList(k, :), 'DisplayName', labelList{k})
                xlabel('Time [s]')
                ylabel('LOS rate [deg/s]')
                grid on
                box on
            end
            legend()
        end
    end
end