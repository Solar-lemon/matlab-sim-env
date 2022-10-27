classdef Scope < SimObject
    properties
        varNames
    end
    methods
        function obj = Scope(varNames, interval, name)
            arguments
                varNames cell
                interval = -1;
                name = [];
            end
            obj = obj@SimObject(interval, name);
            obj.varNames = varNames;
        end

        function plot(obj)
            varKeys = obj.logger.keys();
            varKeys(find(varKeys == 't', 1)) = [];

            try
                t = obj.history('t');
            catch
                error('No key exists for the time variable')
            end

            for i = 1:numel(varKeys)
                varName = varKeys{i};
                var = obj.history(varName);

                figure();
                hold on
                for j = 1:size(varName, 1)
                    plot(t, var(j, :), 'DisplayName', strcat(varName, "_", num2str(i)))
                    xlabel("Time (s)")
                    ylabel("Value")
                    grid on
                end
                legend()
            end
        end
    end
    methods(Access=protected)
        function out = forward_(obj, varargin)
            obj.logger.append({'t'}, {obj.time});
            obj.logger.append(obj.varNames, varargin);
            out = [];
        end
    end
end