classdef ParallelSimulator < handle
    properties
        data
        paramNums
        paramLists
        paramSetList
        totalSimNum
        simulationFun
    end
    methods
        function obj = ParallelSimulator()
            obj.data = containers.Map();
            obj.simulationFun = @obj.simulateModel;
        end
        
        function attachParamLists(obj, varargin)
            % For example, assume that we have
            % k possible choices for parameter a,
            % l possible choices for parameter b,
            % m possible choices for parameter c.
            % Then
            % varargin = {paramAList, paramBList, paramCList}
            % where
            % paramAList = [a_1, ..., a_k] (d_1xk matrix) or {a_1, ..., a_k},
            % paramBList = [b_1, ..., b_l] (d_2xl matrix) or {b_1, ..., b_l},
            % paramCList = [c_1, ..., c_m] (d_3xm matrix) or {c_1, ..., c_m}
            % paramNums = [k, l, m];
            
            obj.paramLists = varargin;
            
            N = numel(varargin);
            obj.paramNums = zeros(1, N);
            for n = 1:N
                obj.paramNums(n) = numel(varargin{n});
            end
            obj.totalSimNum = prod(obj.paramNums);
            
            obj.paramSetList = cell(1, obj.totalSimNum);
            for i = 1:obj.totalSimNum
                subs = cell(1, N);
                [subs{:}] = ind2sub(obj.paramNums, i);
                paramSet = cell(1, N);
                for n = 1:N
                    if isa(varargin{n}, 'numeric')
                        paramSet{n} = varargin{n}(:, subs{n});
                    else
                        paramSet{n} = varargin{n}{subs{n}};
                    end
                end
                obj.paramSetList{i} = paramSet;
            end
        end
        
        function attachSimulationFun(obj, simulationFun)
            % simulationFun should be defined as
            % [simData, model] = simulationFun(i, param1, ..., paramN)
            % simData should be simulation data defined using a structure.
            if nargin < 2 || isempty(simulationFun)
                simulationFun = @obj.simulateModel;
            end
            obj.simulationFun = simulationFun;
        end
        
        function simulate(obj)
            pool = gcp;
            numWorkers = pool.NumWorkers;
            dataQueue = parallel.pool.DataQueue;
            afterEach(dataQueue, @showProgress);
            
            totalSimNum_ = obj.totalSimNum;
            doneSimNum = 0;
            function showProgress(~)
                doneSimNum = doneSimNum + 1;
                fprintf("[Simulator] [%d/%d] Simulation has been finished.\n",...
                    doneSimNum, totalSimNum_);
            end
            
            fprintf("[Simulator] Total %d number of cases will be simulated. \n", totalSimNum_)
            fprintf("[Simulator] Simulating... \n")
            tic
            tempData = cell(1, totalSimNum_);
            parfor (i = 1:totalSimNum_, numWorkers)
                paramSet = obj.paramSetList{i};
                tempData{i} = obj.simulationFun(i, paramSet{:});
                send(dataQueue, i);
            end
            elapsedTime = toc;
            fprintf("[Simulator] The total elapsed time: %.2f [s] \n", elapsedTime);
            fprintf("[Simulator] The average time taken for each simulation: %.2f [s] \n",...
                elapsedTime/totalSimNum_);
            
            if ~isempty(tempData{1})
                keySet = fieldnames(tempData{1});
                for i = 1:numel(keySet)
                    key = keySet{i};
                    matrixList = List();
                    for j = 1:obj.totalSimNum
                        indivData = tempData{j};
                        value = getfield(indivData, key);
                        matrixList.append(value);
                    end
                    obj.data(key) = matrixList;
                end
            end
            delete(gcp('nocreate'))
        end
        
        function [simData, model] = simulateSingle(obj, varargin)
            % varargin = {param1, ..., paramN};
            i = nan;
            [simData, model] = obj.simulationFun(i, varargin{:});
            model.plot();
            model.report();
        end
        
        function out = get(obj, keySet)
            if nargin < 2
                keySet = obj.data.keys();
            end
            out = cell(size(keySet));
            for i = 1:numel(out)
                out{i} = obj.data(keySet{i}).toMatrix();
            end
        end
        
        function save(obj, filePath)
            if nargin < 2 || isempty(filePath)
                if ~isfolder("data")
                    mkdir("data")
                end
                if ~isfolder("data/parSim")
                    mkdir("data/parSim")
                end
                filePath = "data/parSim/data.mat";
            end
            C = [keys(obj.data); values(obj.data)];
            S = struct(C{:});
            save(filePath,'-struct','S')
        end
        
        % to be implemented
        function [simData, model] = simulateModel(obj, i, varargin)
            % implement this method if needed
            fprintf("Attach a simulationFun or implement simulateModel method! \n")
        end
    end
end
        