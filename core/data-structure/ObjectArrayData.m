classdef ObjectArrayData < ArrayData
    properties
        
    end
    methods
        function obj = ObjectArrayData(initSpaceSize, name)
            if nargin < 2 || isempty(name)
                name = "objectArrayData";
            end
            if nargin < 1
                initSpaceSize = [];
            end
            obj = obj@ArrayData(initSpaceSize, name);
            initializeFreeSpace(obj);
        end
        
        % implement
        function out = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            
            if numel(index) == 1
                out = obj.dataValue{1, index};
            else
                out = obj.dataValue(1, index);
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
            
            if numel(index) == 1
                objects = {obj.get(index)};
            else
                objects = obj.get(index);
            end
            initSpaceSize = numel(index);
            newObj = ObjectArrayData(initSpaceSize, obj.name);
            newObj.append(objects{:});
        end
        
        % implement
        function append(obj, varargin)
            inDataNum = numel(varargin);
            while ~(obj.dataNum + inDataNum <= size(obj.dataValue, 2))
                doubleSpaceSize(obj);
            end
            obj.dataValue(:, obj.dataNum + 1:obj.dataNum + inDataNum) = varargin;
            obj.dataNum = obj.dataNum + inDataNum;
        end
        
        % implement
        function clear(obj)
            obj.dataValue = cell(1, obj.initSpaceSize);
            obj.dataNum = 0;
        end
    end
    
    methods(Access = protected)
        function initializeFreeSpace(obj)
            obj.dataValue = cell(1, obj.initSpaceSize);
        end
        
        function out = isFreeSpace(obj, inDataNum)
            out = (obj.dataNum + inDataNum <= size(obj.dataValue, 2));
        end
        
        function doubleSpaceSize(obj)
            prevData  = obj.dataValue;
            spaceSize = 2*size(prevData, 2);
            obj.dataValue  = cell(1, spaceSize);
            obj.dataValue(:, 1:size(prevData, 2)) = prevData;
        end
    end
    
    methods(Static)
        function obj = initializeWithObjects(dataValue, name)
            if nargin < 2
                name = "objectArrayData";
            end
            initSpaceSize = size(dataValue, 2);
            obj = ObjectArrayData(initSpaceSize, name);
            obj.append(dataValue{:});
        end
        
        function test()
            clc
            close all
            
            rng(2021)
            arrayData = ObjectArrayData();
            arrayData.append(rand(2, 3));
            fprintf('== Initial append == \n')
            fprintf('numel(arrayData) \n')
            disp(num2str(numel(arrayData)))
            fprintf('arrayData.get(1): \n')
            disp(num2str(arrayData.get(1)))
            
            arrayData.append(rand(2, 3), rand(2, 3))
            fprintf('== Additional append == \n')
            fprintf('numel(arrayData): \n')
            disp(num2str(numel(arrayData)))
            fprintf('arrayData.get(1:3): \n')
            disp(arrayData.get(1:3))
            
            subData = arrayData.subdata(1:2);
            fprintf('== Get subdata == \n')
            fprintf('subData = arrayData.subdata(1:2) \n')
            fprintf('subData.get(1): \n')
            disp(num2str(subData.get(1)))
            fprintf('subData.get(2): \n')
            disp(num2str(subData.get(2)))
        end
    end
end