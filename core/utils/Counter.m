classdef Counter < handle
    properties
        count
    end
    methods
        function obj = Counter(initCount)
            arguments
                initCount = 0;
            end
            obj.count = initCount;
        end

        function reset(obj, count)
            arguments
                obj
                count = 0;
            end
            obj.count = count;
        end

        function out = next(obj)
            obj.count = obj.count + 1;
            out = obj.count;
        end
    end
end