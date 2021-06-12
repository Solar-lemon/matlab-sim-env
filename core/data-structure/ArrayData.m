classdef(Abstract) ArrayData < handle
    properties
        initSpaceSize
        dataNum
        dataValue
        name
    end
    methods
        function obj = ArrayData(initSpaceSize, name)
            if nargin < 2 || isempty(name)
                name = "arrayData";
            end
            if nargin < 1 || isempty(initSpaceSize)
                initSpaceSize = 100;
            end
            obj.initSpaceSize = initSpaceSize;
            obj.dataNum = 0;
            obj.name = name;
        end
        
        function out = numel(obj)
            out = obj.dataNum;
        end
        
        function out = isempty(obj)
            out = (obj.dataNum == 0);
        end
    end
    methods(Abstract)
        get(obj, index)
        subdata(obj, index)
        append(obj, data)
        clear(obj)
    end
end