classdef MatStackedData < StackedData
    properties
        
    end
    methods
        function obj = MatStackedData(initSpaceSize, name)
            % obj.dataValue: {MatrixData; MatrixData; ...}
            if nargin < 2 || isempty(name)
                name = "matStackedData";
            end
            if nargin < 1
                initSpaceSize = [];
            end
            obj = obj@StackedData(initSpaceSize, name);
        end
        
        % override
        function append(obj, varargin)
            % varargin = {value1, ..., valueK, multiple} or
            % varargin = {value1, ..., valueK}
            if isa(varargin{end}, 'logical')
                stackedNum = numel(varargin) - 1;
                multiple = varargin{end};
            else
                stackedNum = numel(varargin);
                multiple = false;
            end
            
            if isempty(obj.dataValue)
                obj.dataValue = cell(stackedNum, 1);
                for k = 1:stackedNum
                    obj.dataValue{k} = MatrixData();
                end
            end
            
            for k = 1:stackedNum
                data = varargin{k};
                obj.dataValue{k}.append(data, multiple);
                obj.dataNum = max(obj.dataNum, obj.dataValue{k}.dataNum);
            end
        end
        
        % override
        function varargout = get(obj, index)
            if nargin < 2 || isempty(index)
                index = 1:obj.dataNum;
            end
            if any(index > obj.dataNum) || any(index < 1)
                error("The index is out of the range")
            end
            
            varargout = cell(1, nargout);
            for k = 1:nargout
                varargout{k} = obj.dataValue{k}.get(index);
            end
        end
        
        % override
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
                subDataValue{k} = obj.dataValue{k}.get(index);
            end
            
            multiple = (numel(index) > 1);
            newObj = MatStackedData();
            newObj.append(subDataValue{:}, multiple);
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            rng(2021)
            matStackedData = MatStackedData();
            
            dt = 0.1;
            time = 0;
            pos = [0; 0];
            vel = [2; 1];
            theta = 0;
            omega = 0.1;
            
            for i = 1:10
                rotation = [...
                    cos(theta), -sin(theta);
                    sin(theta), cos(theta)];
                matStackedData.append(time, pos, rotation);
                
                time = time + dt;
                pos = pos + dt*vel;
                theta = theta + dt*omega;
            end
            [timeList, posList, rotationList] = matStackedData.get();
            fprintf("== Test for MatStackedData == \n")
            fprintf("timeList: \n")
            disp(timeList)
            fprintf("posList: \n")
            disp(posList)
            fprintf("size(rotationList): \n")
            disp(size(rotationList))
            fprintf("rotationList(:, :, 10): \n")
            disp(rotationList(:, :, 10))
            
            subData = matStackedData.subdata(2:4);
            [subTimeList, subPosList, subRotationList] = subData.get();
            fprintf("subdata = matStackedData.subdata(2:4) \n")
            fprintf("subTimeList: \n")
            disp(subTimeList)
            fprintf("subPosList: \n")
            disp(subPosList)
            fprintf("size(subRotationList): \n")
            disp(size(subRotationList))
        end
    end
end