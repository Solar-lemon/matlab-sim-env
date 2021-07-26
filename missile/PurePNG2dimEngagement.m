classdef PurePNG2dimEngagement < MultipleSystem
    properties
        missile
        target
        kinematics
        purePng
        prevRange = inf
    end
    methods
        function obj = PurePNG2dimEngagement(missileState)
            if nargin < 1
                missileState = [-5E3; 3E3; 300; deg2rad(-5)];
            end
            obj = obj@MultipleSystem();
            
            obj.missile = PlanarMissile3dof(missileState);
            obj.target = PlanarStationaryVehicle3dof([0; 0]);
            obj.kinematics = EngKinematics(obj.missile, obj.target);
            obj.purePng = DiscreteFunction(PurePNG2dim(3), 1/40); % 40 Hz
            
            obj.attachDynSystems({obj.missile});
            obj.attachDiscSystems({obj.purePng});
        end
        
        % implement
        function forward(obj)
            v_M = obj.missile.state(3);
            omega = obj.kinematics.losRate;
            r = obj.kinematics.range;
            
            a_M = obj.purePng.forward(v_M, omega);
            obj.missile.forward([0; a_M]);
            
            if obj.logger.toLog()
                obj.logger.forward(omega, r);
                obj.logger.forwardVarNames('losRate', 'range');
            end
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
            title('2-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPos(figs{1});
            
            temp = obj.historyByVarNames('time', 'losRate');
            [timeList, losRateList] = temp{:};
            losRateList = rad2deg(losRateList);
            
            figs{2} = figure();
            hold on
            title('LOS rate')
            plot(timeList, losRateList)
            xlabel('Time [s]')
            ylabel('LOS rate [deg/s]')
            grid on
            box on
        end
    end
end