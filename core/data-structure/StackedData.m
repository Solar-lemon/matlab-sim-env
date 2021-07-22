classdef(ConstructOnLoad) StackedData < ArrayData
    properties
        stackedNum
    end
    methods
        function obj = StackedData(initSpaceSize)
            % obj.dataValue: {ArrayData; ArrayData; ... }
            if nargin < 1 || isempty(initSpaceSize)
                initSpaceSize = 100;
            end
            obj = obj@ArrayData(initSpaceSize);
            obj.name = "stackedData";
        end
        
        % implement
        function varargout = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            
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
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            
            subDataValue = cell(size(obj.dataValue));
            for k = 1:obj.stackedNum
                subDataValue{k} = obj.dataValue{k}.subdata(index);
            end
            initSpaceSize = numel(index);
            newObj = StackedData(initSpaceSize);
            newObj.dataValue = subDataValue;
        end
        
        % implement
        function append(obj, varargin)
            if isempty(obj.dataValue)
                obj.stackedNum = numel(varargin);
                obj.dataValue = cell(obj.stackedNum, 1);
                for k = 1:obj.stackedNum
                    obj.dataValue{k} = ObjectArrayData();
                end
            end
            assert(numel(varargin) == obj.stackedNum,...
                "The number of the input data does not match the number of the stacked data")
            
            for k = 1:obj.stackedNum
                data = varargin{k};
                obj.dataValue{k}.append(data);
                obj.dataNum = max(obj.dataNum, obj.dataValue{k}.dataNum);
            end
        end
        
        % implement
        function clear(obj)
            for k = 1:obj.stackedNum
                if ~isempty(obj.dataValue{k})
                    obj.dataValue{k}.clear();
                end
            end
            obj.dataNum = 0;
        end
    end
end