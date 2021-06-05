classdef VectorData < ArrayData
    properties
        dim
    end
    methods
        function obj = VectorData(dim, initSpaceSize, name)
            if nargin < 3 || isempty(name)
                name = "vectorData";
            end
            if nargin < 2
                initSpaceSize = [];
            end
            if nargin < 1
                dim = [];
            end
            
            obj = obj@ArrayData(initSpaceSize, name);
            obj.dim = dim;
            if ~isempty(dim)
                initializeFreeSpace(obj);
            end
        end
        
        % implement
        function out = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            out = obj.dataValue(:, index);
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
            initSpaceSize = numel(index);
            newObj = VectorData([], initSpaceSize, obj.name);
            newObj.append(dataValue);
        end
        
        % implement
        function append(obj, inDataValue)
            if isempty(inDataValue)
                return
            end
            if isempty(obj.dim)
                obj.dim = size(inDataValue, 1);
            end
            if isempty(obj.dataValue)
                initializeFreeSpace(obj);
            end
            
            inDataNum = size(inDataValue, 2);
            while ~(obj.dataNum + inDataNum <= size(obj.dataValue, 2))
                doubleSpaceSize(obj);
            end
            
            obj.dataValue(:, obj.dataNum + 1:obj.dataNum + inDataNum) = inDataValue;
            obj.dataNum = obj.dataNum + inDataNum;
        end
        
        % implement
        function clear(obj)
            if isempty(obj.dim)
                obj.dataValue = [];
                obj.dataNum = 0;
            else
                obj.dataValue = nan(obj.dim, obj.initSpaceSize);
                obj.dataNum = 0;
            end
        end
        
        % operator overloading
        function newObj = horzcat(varargin)
            indivValues = cell(size(varargin));
            for i = 1:numel(varargin)
                indivValues{i} = varargin{i}.get();
            end
            dataValue = horzcat(indivValues{:});
            newObj = VectorData.initializeWithValue(dataValue);
        end
        
        % operator overloading
        function newObj = vertcat(varargin)
            arrayNum = numel(varargin);
            maxDataNum = 1;
            for i = 1:arrayNum
                vectorData = varargin{i};
                if isempty(vectorData.dim) || (vectorData.dim <= 0)
                    error("The dimension of the vector data is not correct")
                end
                maxDataNum = max(maxDataNum, numel(vectorData));
            end
            
            indivValues = cell(size(varargin));
            for i = 1:arrayNum
                vectorData = varargin{i};
                value_ = nan(vectorData.dim, maxDataNum);
                value_(:, 1:numel(vectorData)) = vectorData.get();
                indivValues{i} = value_;
            end
            dataValue = vertcat(indivValues{:});
            newObj = VectorData.initializeWithValue(dataValue);
        end
    end
    
    methods(Access = protected)
        function initializeFreeSpace(obj)
            obj.dataValue = nan(obj.dim, obj.initSpaceSize);
        end
        
        function out = isFreeSpace(obj, inDataNum)
            out = (obj.dataNum + inDataNum <= size(obj.dataValue, 2));
        end
        
        function doubleSpaceSize(obj)
            prevData  = obj.dataValue;
            spaceSize = 2*size(prevData, 2);
            obj.dataValue  = nan(obj.dim, spaceSize);
            obj.dataValue(:, 1:size(prevData, 2)) = prevData;
        end
    end
    
    methods(Static)
        function obj = initializeWithValue(dataValue, name)
            if nargin < 2
                name = "vectorData";
            end
            dim = size(dataValue, 1);
            initSpaceSize = size(dataValue, 2);
            obj = VectorData(dim, initSpaceSize, name);
            obj.append(dataValue);
        end
        
        function test()
            clear
            clc
            close all
            
            rng(2021)
            initSpaceSize = 10;
            pos = VectorData(2, initSpaceSize);
            pos.append(rand(2, 3));
            fprintf('== Initial append == \n')
            fprintf('pos.length(): \n')
            disp(numel(pos))
            fprintf('pos.get(): \n')
            disp(num2str(pos.get()))
            
            pos.append(rand(2, 3));
            fprintf('== Additional append == \n')
            fprintf('pos.get(): \n')
            disp(num2str(pos.get()))
            
            vel = VectorData.initializeWithValue(rand(2, 4));
            posVel = [pos; vel];
            fprintf('== Vertical concatenation == \n')
            fprintf('pos.get(): \n')
            disp(num2str(pos.get()))
            fprintf('vel.get(): \n')
            disp(num2str(vel.get()))
            fprintf('posVel.get(): \n')
            disp(num2str(posVel.get()))
            
            subPosVel = posVel.subdata(2:4);
            fprintf('== Get subPosVel == \n')
            fprintf('subPosVel = posVel.subdata(2:4) \n')
            fprintf('subPosVel.get(): \n')
            disp(num2str(subPosVel.get()))
        end
    end
end