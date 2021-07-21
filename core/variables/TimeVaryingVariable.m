classdef TimeVaryingVariable < Variable
    properties
        useBaseFunction
        shapingFun
    end
    methods
        function obj = TimeVaryingVariable(shapingFun)
            obj = obj@Variable(shapingFun(0));
            obj.useBaseFunction = isa(shapingFun, 'BaseFunction');
            obj.shapingFun = shapingFun;
        end
        
        function forward(obj, time)
            if obj.useBaseFunction
                obj.value = obj.shapingFun.forward(time);
            else
                obj.value = obj.shapingFun(time);
            end
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            shapingFun = @(t) sin(0.05*pi*t);
            u = TimeVaryingVariable(shapingFun);
            time = 0;
            dt = 0.1;
            
            timeList = nan(1, 100);
            uList = nan(1, 100);
            for i = 1:100
                u.forward(time);
                
                timeList(1, i) = time;
                uList(1, i) = u.value;
                
                time = time + dt;
            end
            
            figure();
            hold on
            plot(timeList, uList, '-k')
            xlabel('Time')
            ylabel('Value')
            grid on
            box on
        end
    end
end