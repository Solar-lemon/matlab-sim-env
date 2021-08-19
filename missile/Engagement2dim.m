classdef Engagement2dim < MultipleSystem
    properties
        missile
        target
        kinematics
        prevRange = inf
    end
    methods
        function obj = Engagement2dim(missile, target)
            obj = obj@MultipleSystem();
            
            obj.missile = missile;
            obj.target = target;
            obj.kinematics = EngKinematics(missile, target);
            
            obj.attachDynSystems({obj.missile, obj.target});
        end
        
        % implement
        function forward(obj)
            losAngle = obj.kinematics.losAngle;
            sigma = obj.missile.lookAngle(losAngle);
            omega = obj.kinematics.losRate;
            r = obj.kinematics.range;
            
            obj.target.forward();
            
            if obj.logger.toLog()
                obj.logger.forward(sigma, omega, r);
                obj.logger.forwardVarNames('lookAngle', 'losRate', 'range');
            end
        end
        
        % implement
        function toStop = checkStopCondition(obj)
            toStop = obj.missile.checkStopCondition();
            toStop = toStop...
                || obj.rangeIsIncreasing()...
                || obj.isOutOfView();
            updateRange(obj);
        end
        
        function out = rangeIsIncreasing(obj)
            range = obj.kinematics.range;
            out = (range > obj.prevRange);
        end
        
        function out = isOutOfView(obj)
            % when the target has gone out of the field-of-view
            losAngle = obj.kinematics.losAngle;
            sigma = obj.missile.lookAngle(losAngle);
            out = (sigma > obj.missile.fovLimit);
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
            figs{1}.Name = "2-dim Fligh Path";
            hold on
            title('2-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPath(figs{1});
            daspect([1 1 1])
            
            temp = obj.historyByVarNames('time', 'lookAngle', 'losRate');
            [timeList, sigmaList, losRateList] = temp{:};
            sigmaList = rad2deg(sigmaList);
            losRateList = rad2deg(losRateList);
            
            figs{2} = figure();
            figs{2}.Name = "Look angle";
            hold on
            title("Look angle")
            plot(timeList(1:end - 1), sigmaList(1:end - 1),...
                'DisplayName', 'sigma')
            xlabel("Time [s]")
            ylabel("Look angle [deg]")
            grid on
            box on
            legend()
            
            figs{3} = figure();
            figs{3}.Name = "LOS rate";
            hold on
            title("LOS rate")
            plot(timeList, losRateList)
            xlabel("Time [s]")
            ylabel("LOS rate [deg/s]")
            grid on
            box on
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end