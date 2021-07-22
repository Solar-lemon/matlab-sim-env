classdef(ConstructOnLoad) MatStackedData < StackedData
    properties(Dependent)
        matValues
    end
    methods
        function obj = MatStackedData(initSpaceSize)
            % obj.dataValue: {MatrixData; MatrixData; ...}
            if nargin < 1
                initSpaceSize = [];
            end
            obj = obj@StackedData(initSpaceSize);
            obj.name = "matStackedData";
        end
        
        % override
        function append(obj, varargin)
            % varargin = {value1, ..., valueK, multiple} or
            % varargin = {value1, ..., valueK}
            if isempty(obj.dataValue)
                if isa(varargin{end}, 'logical')
                    obj.stackedNum = numel(varargin) - 1;
                else
                    obj.stackedNum = numel(varargin);
                end
                obj.dataValue = cell(obj.stackedNum, 1);
                for k = 1:obj.stackedNum
                    obj.dataValue{k} = MatrixData();
                end
            end
            
            if isa(varargin{end}, 'logical')
                multiple = varargin{end};
            else
                multiple = false;
            end
            
            for k = 1:obj.stackedNum
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
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            
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
            assert(all(index >= 1) & all(index <= obj.dataNum),...
                "The index is out of the range")
            
            subDataValue = cell(size(obj.dataValue));
            for k = 1:obj.stackedNum
                subDataValue{k} = obj.dataValue{k}.get(index);
            end
            
            multiple = (numel(index) > 1);
            newObj = MatStackedData();
            newObj.append(subDataValue{:}, multiple);
        end
        
        function out = matValuesByVarNames(obj, varargin)
            % out = matValueForName1 for a single name
            % out = {matValueForName1, ... matValueForNameN} for multiple
            % names
            assert(~isempty(obj.varNames),...
                "Define variable names first.")
            varInd = cell2mat(obj.varNames.values(varargin));
            out = obj.matValues(varInd);
            if numel(varInd) == 1
                out = out{:};
            end
        end
        
        function save(obj, filePath)
            if isempty(obj)
                fprintf("There is no data to save \n");
                return
            end
            filePath = convertCharsToStrings(filePath);
            strArray = split(filePath, "/");
            folder = join(strArray(1:end - 1), "/");
            if ~isfolder(folder)
                mkdir(folder)
            end
            
            dataToSave.dataNum = obj.dataNum;
            dataToSave.matValues = obj.matValues;
            dataToSave.varNames = obj.varNames;
            save(filePath, '-struct', 'dataToSave');
        end
        
        function load(obj, filePath)
            loadedData = load(filePath);
            obj.clear();
            
            multiple = (loadedData.dataNum > 1);
            obj.append(loadedData.matValues{:}, multiple);
            obj.varNames = loadedData.varNames;
        end
    end
    
    % set and get methods
    methods
        function out = get.matValues(obj)
            assert(obj.dataNum > 0, "No data is present.")
            out = cell(obj.stackedNum, 1);
            for k = 1:obj.stackedNum
                out{k} = obj.dataValue{k}.get();
            end
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