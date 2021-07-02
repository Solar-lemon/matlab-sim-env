classdef MatrixData < ArrayData
    properties
        shape
        accessIndex
    end
    methods
        function obj = MatrixData(initSpaceSize, name)
            if nargin < 2 || isempty(name)
                name = "matrixData";
            end
            if nargin < 2
                initSpaceSize = [];
            end
            
            obj = obj@ArrayData(initSpaceSize, name);
        end
        
        % implement
        function append(obj, inDataValue, multiple)
            % if multipe = false, inDataValue should be a single datum
            % matrix(sz1, sz2, ..., szN)
            % if multipe = true,  inDataValue should be
            % matrix(sz1, sz2, ..., szN, inDataNum)
            if nargin < 3
                multiple = false;
            end
            
            % initialization
            if isempty(obj.shape)
                initializeShape(obj, inDataValue, multiple);
            end
            
            if multiple
                inDataNum = size(inDataValue, obj.ndims + 1);
            else
                inDataNum = 1;
            end
            
            if isempty(obj.dataValue)
                initializeFreeSpace(obj);
            end
            while ~(obj.dataNum + inDataNum <= size(obj.dataValue, obj.ndims + 1))
                doubleSpaceSize(obj);
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
            
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            out = obj.dataValue(obj.accessIndex{:}, index);
        end
        
        % implement
        function newObj = subdata(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            
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
            obj.dataValue = nan([obj.shape, obj.initSpaceSize]);
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
        function obj = initializeWithValue(dataValue, multiple, name)
            if nargin < 3 || isempty(name)
                name = "matrixData";
            end
            if nargin < 2 || isempty(multiple)
                multiple = true;
            end
            obj = MatrixData([], name);
            obj.append(dataValue, multiple);
        end
        
        function test()
            clc
            close all
            
            rng(2021)
            cov1 = MatrixData();
            cov2 = MatrixData();
            cov2.append(rand(3, 3, 2), true);
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