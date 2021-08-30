classdef Engagement2dim < MultipleSystem
    properties
        missile
        target
        kinematics
        prevRange = inf
        interceptionCriteria = 1
    end
    methods
        function obj = Engagement2dim(missile, target)
            obj = obj@MultipleSystem();
            
            obj.missile = missile;
            obj.target = target;
            obj.kinematics = EngKinematics(missile, target);
            
            obj.missile.attachEngKinematics(obj.kinematics);
            obj.attachDynSystems({obj.missile, obj.target});
        end
        
        % override
        function reset(obj)
            reset@MultipleSystem(obj);
            obj.prevRange = inf;
        end
        
        % implement
        function forward(obj)
            sigma = obj.missile.lookAngle();
            lam = obj.kinematics.losAngle;
            omega = obj.kinematics.losRate;
            r = obj.kinematics.range;
            
            p_M = obj.missile.pos;
            p_T = obj.target.pos;
            
            obj.target.forward();
            
            if obj.logger.toLog()
                obj.logger.forward(sigma, lam, omega, r, p_M, p_T);
                obj.logger.forwardVarNames('sigma', 'lam', 'omega', 'r', 'p_M', 'p_T');
            end
        end
        
        % implement
        function toStop = checkStopCondition(obj)
            toStop = obj.missile.checkStopCondition();
            toStop = toStop...
                || obj.rangeIsIncreasing();
            updateRange(obj);
        end
        
        function out = rangeIsIncreasing(obj)
            range = obj.kinematics.range;
            out = (range > obj.prevRange);
        end
        
        function updateRange(obj)
            obj.prevRange = obj.kinematics.range;
        end
        
        function d_miss = missDistance(obj)
            p_M = obj.historyByVarNames('p_M');
            p_T = obj.historyByVarNames('p_T');
            d_miss = MissileUtils.missDistance(p_M, p_T);
        end
        
        function report(obj)
            fprintf("[Engagement] Miss distance: %.4f [m] \n", obj.missDistance())
        end
        
        function figs = plot(obj)
            set(0,'DefaultFigureWindowStyle','docked')
            figs = cell(4, 1);
            
            obj.missile.plot();
            
            figs{1} = figure();
            figs{1}.Name = "2-dim Fligh Path";
            hold on
            title('2-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPath(figs{1});
            daspect([1 1 1])
            
            temp = obj.historyByVarNames('time', 'sigma', 'lam', 'omega');
            [timeList, sigmaList, lamList, omegaList] = temp{:};
            sigmaList = rad2deg(sigmaList);
            lamList = rad2deg(lamList);
            omegaList = rad2deg(omegaList);
            
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
            figs{3}.Name = "LOS angle";
            hold on
            title("Los angle")
            plot(timeList(1:end - 1), lamList(1:end - 1),...
                'DisplayName', 'lambda')
            xlabel("Time [s]")
            ylabel("LOS angle [deg]")
            grid on
            box on
            legend()
            
            figs{4} = figure();
            figs{4}.Name = "LOS rate";
            hold on
            title("LOS rate")
            plot(timeList, omegaList)
            xlabel("Time [s]")
            ylabel("LOS rate [deg/s]")
            grid on
            box on
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end