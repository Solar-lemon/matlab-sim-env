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
            losVector = obj.kinematics.losVector;
            sigma = obj.missile.lookAngle(losVector);
            omega = obj.kinematics.losRate;
            r = obj.kinematics.range;
            
            a_M = obj.purePng.forward(R_VL, v_M, omega);
            obj.missile.forward(a_M);
            
            if obj.logger.toLog()
                obj.logger.forward(sigma, omega, r);
                obj.logger.forwardVarNames('lookAngle', 'losRate', 'range');
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
            set(0,'DefaultFigureWindowStyle','docked')
            figs = cell(2, 1);
            
            obj.missile.plot();
            
            figs{1} = figure();
            figs{1}.Name = "3-dim Flight Path";
            hold on
            title('3-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPos(figs{1});
            
            temp = obj.historyByVarNames('time', 'lookAngle', 'losRate');
            [timeList, sigmaList, losRateList] = temp{:};
            sigmaList = rad2deg(sigmaList);
            losRateList = rad2deg(losRateList);
            
            figs{2} = figure();
            figs{2}.Name = "Look angle";
            hold on
            title("Look angle")
            plot(timeList(1:end - 1), sigmaList(1:end - 1), 'DisplayName', 'sigma')
            xlabel('Time [s]')
            ylabel('Look angle [deg]')
            grid on
            box on
            legend()
            
            figs{3} = figure();
            figs{3}.Name = "LOS rate";
            hold on
            title('LOS rate')
            labelList = {'omega_x', 'omega_y', 'omega_z'};
            for k = 1:3
                subplot(3, 1, k)
                plot(timeList(1:end - 1), losRateList(k, 1:end - 1),...
                    'DisplayName', labelList{k})
                xlabel('Time [s]')
                ylabel('LOS rate [deg/s]')
                grid on
                box on
            end
            legend()
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end