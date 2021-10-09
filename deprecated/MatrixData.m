classdef(ConstructOnLoad) MatrixData < ArrayData
    properties
        type
        shape
        accessIndex
    end
    methods
        function obj = MatrixData(initSpaceSize)
            if nargin < 2
                initSpaceSize = [];
            end
            
            obj = obj@ArrayData(initSpaceSize);
            obj.name = "matrixData";
        end
        
        % implement
        function append(obj, inDataValue)
            % if multipe = false, inDataValue should be a single datum
            % matrix(sz1, sz2, ..., szN)
            
            % initialization
            if isempty(obj.type)
                obj.initializeType(inDataValue);
            end
            if isempty(obj.shape)
                obj.initializeShape(inDataValue, false);
            end
            if isempty(obj.dataValue)
                obj.initializeFreeSpace();
            end
            
            while ~(obj.dataNum + 1 <= size(obj.dataValue, obj.ndims + 1))
                obj.doubleSpaceSize();
            end
            obj.dataValue(obj.accessIndex{:}, obj.dataNum + 1) ...
                = inDataValue;
            obj.dataNum = obj.dataNum + 1;
        end
        
        function appendMultiple(obj, inDataValue)
            % inDataValue should be
            % matrix(sz1, sz2, ..., szN, inDataNum)
            if isempty(obj.type)
                obj.initializeType(inDataValue);
            end
            if isempty(obj.shape)
                obj.initializeShape(inDataValue, true);
            end
            if isempty(obj.dataValue)
                obj.initializeFreeSpace();
            end
            
            inDataNum = size(inDataValue, obj.ndims + 1);
            while ~(obj.dataNum + inDataNum <= size(obj.dataValue, obj.ndims + 1))
                obj.doubleSpaceSize();
            end
            obj.dataValue(obj.accessIndex{:}, obj.dataNum + 1:obj.dataNum + inDataNum) ...
                = inDataValue;
            obj.dataNum = obj.dataNum + inDataNum;
        end
        
        % implement
        function out = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            out = obj.dataValue(obj.accessIndex{:}, index);
        end
        
        % implement
        function newObj = subdata(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            
            dataValue = obj.get(index);
            multiple = (numel(index) > 1);
            newObj = MatrixData.initializeWithValue(dataValue, multiple);
        end
        
        % implement
        function clear(obj)
            if isempty(obj.shape)
                obj.dataValue = [];
            else
                obj.dataValue = nan([obj.shape, obj.initSpaceSize]);
            end
            obj.dataNum = 0;
        end
        
        function out = ndims(obj)
            out = numel(obj.shape);
        end
        
        % operator overloading
        function newObj = horzcat(varargin)
            indivValues = cell(size(varargin));
            ndims = varargin{1}.ndims;
            for i = 1:numel(varargin)
                indivValues{i} = varargin{i}.get();
            end
            dataValue = cat(ndims + 1, indivValues{:});
            multiple = (size(dataValue, ndims + 1) > 1);
            newObj = MatrixData.initializeWithValue(dataValue, multiple);
        end
    end
    
    methods(Access = protected)
        function initializeType(obj, inDataValue)
            obj.type = class(inDataValue);
        end
        
        function initializeShape(obj, inDataValue, multiple)
            if multiple
                obj.shape = size(inDataValue, 1:ndims(inDataValue) - 1);
            else
                obj.shape = size(inDataValue);
                if obj.shape(end) == 1
                    obj.shape = obj.shape(1:end - 1);
                end
            end
            
            obj.accessIndex = cell(1, obj.ndims);
            for k = 1:obj.ndims
                obj.accessIndex{k} = 1:size(inDataValue, k);
            end
        end
        
        function initializeFreeSpace(obj)
            obj.dataValue = zeros([obj.shape, obj.initSpaceSize], obj.type);
        end
        
        function out = isFreeSpace(obj, inDataNum)
            out = (obj.dataNum + inDataNum ...
                <= size(obj.dataValue, obj.ndims + 1));
        end
        
        function doubleSpaceSize(obj)
            prevData = obj.dataValue;
            spaceSize = 2*size(prevData, obj.ndims + 1);
            obj.dataValue = nan([obj.shape, spaceSize]);
            obj.dataValue(obj.accessIndex{:}, 1:size(prevData, obj.ndims + 1)) = prevData;
        end
    end
    
    methods(Static)
        function obj = initializeWithValue(dataValue, multiple)
            if nargin < 2 || isempty(multiple)
                multiple = true;
            end
            obj = MatrixData();
            obj.name = "matrixData";
            if multiple
                obj.appendMultiple(dataValue);
            else
                obj.append(dataValue);
            end
        end
        
        function test()
            clc
            close all
            
            rng(2021)
            cov1 = MatrixData();
            cov2 = MatrixData();
            cov2.appendMultiple(rand(3, 3, 2));
            for i = 1:5
                cov1.append(diag(rand(1, 3)));
                cov2.append(diag(rand(1, 3)));
            end
            subCov = cov1.subdata(2:3);
            cov = [cov1, cov2];
            
            fprintf("== Test for MatrixData == \n")
            fprintf("cov1.numel: %d \n", cov1.numel);
            fprintf("cov2.numel: %d \n", cov2.numel);
            fprintf("cov1.get(1): \n");
            disp(cov1.get(1));
            fprintf("cov1.get(2): \n");
            disp(cov1.get(2));
            fprintf("cov1.get(3): \n");
            disp(cov1.get(3));
            fprintf("subCov = cov1.subdata(2:3) \n");
            fprintf("subCov.numel: %d \n", subCov.numel);
            fprintf("cov = [cov1, cov2] \n");
            fprintf("cov.numel: %d \n", cov.numel);
        end
    end
end