classdef(ConstructOnLoad) StackedData < ArrayData
    properties
        stackedNum
        varNames
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
            obj.dataNum = 0;
            for k = 1:obj.stackedNum
                if ~isempty(obj.dataValue{k})
                    obj.dataValue{k}.clear();
                end
            end
        end
        
        function setVarNames(obj, varargin)
            % varargin = {varName1, varName2, ..., varNameN}
            varInd = 1:numel(varargin);
            obj.varNames = containers.Map(...
                varargin, num2cell(varInd));
        end
        
        function out = dataValuesByVarNames(obj, varargin)
            % out = dataValueForName1 for a single name
            % out = {dataValueForName1, ... dataValueForNameN} for multiple
            % names
            assert(~isempty(obj.varNames),...
                "Define variable names first.")
            varInd = cell2mat(obj.varNames.values(varargin));
            out = obj.dataValue(varInd);
            if numel(varInd) == 1
                out = out{:};
            end
        end
    end
end