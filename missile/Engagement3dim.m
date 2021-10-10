classdef Engagement3dim < MultipleSystem
    properties
        missile
        target
        kinematics
        prevRange = inf
        interceptionCriteria = 1
    end
    methods
        function obj = Engagement3dim(missile, target)
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
            
            obj.logger.forward(...
                {'time', 'sigma', 'lam', 'omega', 'r', 'p_M', 'p_T'},...
                {obj.simClock.time, sigma, lam, omega, r, p_M, p_T});
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
            p_M = obj.history('p_M');
            p_T = obj.history('p_T');
            d_miss = MissileUtils.missDistance(p_M, p_T);
        end
        
        function out = accSaturated(obj)
            accSaturated = obj.missile.history('accSaturated');
            out = any(accSaturated);
        end
        
        function report(obj)
            obj.missile.report();
            fprintf("[Engagement] Miss distance: %.4f [m] \n", obj.missDistance())
        end
        
        function figs = plot(obj)
            set(0,'DefaultFigureWindowStyle','docked')
            figs = cell(4, 1);
            
            obj.missile.plot();
            
            figs{1} = figure();
            figs{1}.Name = "3-dim Fligh Path";
            hold on
            title('3-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPath(figs{1});
            daspect([1 1 1])
            
            loggedData = obj.history('time', 'sigma', 'lam', 'omega');
            [timeList, sigmaList, lamList, omegaList] = loggedData{:};
            sigmaList = rad2deg(sigmaList);
            lamList = rad2deg(lamList);
            omegaList = rad2deg(omegaList);
            
            figs{2} = figure();
            figs{2}.Name = "Look angle";
            labelList = ["Lat.", "Lon."];
            for k = 1:2
                subplot(2, 1, k)
                hold on
                title("Look angle")
                plot(timeList(1:end - 1), sigmaList(k, 1:end - 1),...
                    'DisplayName', labelList(k))
                xlabel("Time [s]")
                ylabel("Look angle [deg]")
                grid on
                box on
                legend()
            end
            
            figs{3} = figure();
            figs{3}.Name = "LOS angle";
            title("Los angle")
            labelList = ["azim", "elev"];
            for k = 1:2
                subplot(2, 1, k)
                hold on
                plot(timeList(1:end - 1), lamList(k, 1:end - 1),...
                    'DisplayName', labelList(k))
                xlabel("Time [s]")
                ylabel("LOS angle [deg]")
                grid on
                box on
                legend()
            end
            
            figs{4} = figure();
            figs{4}.Name = "LOS rate";
            title("LOS rate")
            labelList = ["omega_x", "omega_y", "omega_z"];
            for k = 1:3
                subplot(3, 1, k)
                plot(timeList, omegaList(k, :),...
                    'DisplayName', labelList(k))
                xlabel("Time [s]")
                ylabel("LOS rate [deg/s]")
                grid on
                box on
                legend()
            end
            
            set(0,'DefaultFigureWindowStyle','normal')
        end
    end
end