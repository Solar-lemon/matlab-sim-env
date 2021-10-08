classdef Engagement2dim < Engagement3dim
    methods
        function obj = Engagement2dim(missile, target)
            obj = obj@Engagement3dim(missile, target);
        end
        
        % override
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