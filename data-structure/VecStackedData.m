classdef VecStackedData < StackedData
    properties
        
    end
    methods
        function obj = VecStackedData(initSpaceSize, name)
            % obj.dataValue: {VectorData; VectorData; ... }
            if nargin < 2 || isempty(name)
                name = "vecStackedData";
            end
            if nargin < 1 || isempty(initSpaceSize)
                initSpaceSize = 100;
            end
            obj = obj@StackedData(initSpaceSize, name);
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
        function append(obj, varargin)
            stackedNum = numel(varargin);
            if isempty(obj.dataValue)
                obj.dataValue = cell(stackedNum, 1);
                for k = 1:stackedNum
                    obj.dataValue{k} = VectorData();
                end
            end
            
            for k = 1:stackedNum
                data = varargin{k};
                obj.dataValue{k}.append(data);
                obj.dataNum = max(obj.dataNum, obj.dataValue{k}.dataNum);
            end
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            rng(2021)
            vecStackedData = VecStackedData();
            
            dt = 0.1;
            time = 0;
            pos = [0; 0];
            vel = [2; 1];
            for i = 1:10
                vecStackedData.append(time, pos, vel);
                time = time + dt;
                pos = pos + dt*vel;
            end
            [timeList, posList, velList] = vecStackedData.get();
            fprintf('== Appending test == \n')
            fprintf('timeList: \n')
            disp(num2str(timeList))
            fprintf('posList: \n')
            disp(num2str(posList))
            fprintf('velList: \n')
            disp(num2str(velList))
            
            subData = vecStackedData.subdata(2:5);
            [subTimeList, subPosList] = subData.get();
            fprintf('== Get subdata == \n')
            fprintf('[subTimeList, subPosList] = vecStackedData.subdata(2:5).get() \n')
            fprintf('subTimeList: \n')
            disp(num2str(subTimeList.get()))
            fprintf('subPosList: \n')
            disp(num2str(subPosList.get()))
        end
    end
end