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
            obj.attachSimObjects({obj.missile, obj.target});
        end
        
        % override
        function reset(obj)
            reset@MultipleSystem(obj);
            obj.prevRange = inf;
        end
        
        % implement
        function forward(obj)
            obj.target.forward();
        end
        
        % implement
        function [toStop, flag] = checkStopCondition(obj)
            toStop = obj.missile.checkStopCondition();
            if toStop
                flag = 1;
            end
            range = obj.kinematics.range;
            if (range > obj.prevRange)
                toStop = true;
                flag = 2;
            end
            obj.prevRange = range;
        end
        
        function d_miss = missDistance(obj)
            x_M = obj.missile.history('state');
            x_T = obj.target.history('state');
            
            p_M = x_M(1:2, :);
            p_T = x_T(1:2, :);
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
            figs{1}.Name = "2-dim Fligh Path";
            hold on
            title('2-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPath(figs{1});
            daspect([1 1 1])
            
            timeList = obj.missile.history('time');
            x_M = obj.missile.history('state');
            x_T = obj.target.history('state');
            
            relKinematics = RelativeKinematics2dim(x_M, x_T);
            sigmaList = relKinematics.lookAngle();
            lamList = relKinematics.losAngle();
            omegaList = relKinematics.losRate();
            
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