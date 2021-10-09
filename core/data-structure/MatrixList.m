classdef MatrixList < handle
    properties
        initSpaceSize = 1000
        shape
        dataNum = 0
        data
    end
    methods
        function clear(obj)
            obj.shape = [];
            obj.dataNum = 0;
            obj.data = [];
        end
        
        function append(obj, value)
            if isempty(obj.data)
                obj.shape = size(value);
                obj.data = cell(1, obj.initSpaceSize);
            end
            
            if obj.dataNum + 1 > numel(obj.data)
                obj.doubleSpaceSize();
            end
            obj.data{1, obj.dataNum + 1} = value;
            obj.dataNum = obj.dataNum + 1;
        end
        
        function out = get(obj)
            if obj.shape(end) == 1
                out = cat(numel(obj.shape), obj.data{1, :});
            else
                out = cat(numel(obj.shape) + 1, obj.data{1, :});
            end
        end
        
        function out = numel(obj)
            out = obj.dataNum;
        end
        
        function doubleSpaceSize(obj)
            obj.data = [obj.data, cell(1, obj.dataNum)];
        end
    end
end