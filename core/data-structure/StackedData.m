classdef StackedData < ArrayData
    properties
        
    end
    methods
        function obj = StackedData(initSpaceSize, name)
            % obj.dataValue: {ArrayData; ArrayData; ... }
            if nargin < 2 || isempty(name)
                name = "stackedData";
            end
            if nargin < 1 || isempty(initSpaceSize)
                initSpaceSize = 100;
            end
            obj = obj@ArrayData(initSpaceSize, name);
        end
        
        function initialize(obj, varargin)
            stackedNum = numel(varargin);
            obj.dataValue = cell(stackedNum, 1);
            for k = 1:stackedNum
                obj.dataValue{k} = varargin{k};
            end
        end
        
        % implement
        function varargout = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            
            varargout = cell(1, nargout);
            for k = 1:nargout
                varargout{k} = obj.dataValue{k}.subdata(index);
            end
        end
        
        % implement
        function newObj = subdata(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            
            stackedNum = size(obj.dataValue, 1);
            subDataValue = cell(size(obj.dataValue));
            for k = 1:stackedNum
                subDataValue{k} = obj.dataValue{k}.subdata(index);
            end
            initSpaceSize = numel(index);
            newObj = StackedData(initSpaceSize);
            newObj.dataValue = subDataValue;
        end
        
        % implement
        function append(obj, varargin)
            stackedNum = numel(varargin);
            if isempty(obj.dataValue)
                obj.dataValue = cell(stackedNum, 1);
                for k = 1:stackedNum
                    obj.dataValue{k} = ObjectArrayData();
                end
            end
            
            for k = 1:stackedNum
                data = varargin{k};
                obj.dataValue{k}.append(data);
                obj.dataNum = max(obj.dataNum, obj.dataValue{k}.dataNum);
            end
        end
        
        % implement
        function clear(obj)
            stackedNum = size(obj.dataValue, 1);
            for k = 1:stackedNum
                obj.dataValue{k}.clear();
            end
            obj.dataNum = 0;
        end
    end
end