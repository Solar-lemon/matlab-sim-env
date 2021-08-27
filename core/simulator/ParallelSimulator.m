classdef ParallelSimulator < handle
    properties
        data
        paramLists
        paramSetList
        totalSimNum
        simulationFun
    end
    methods
        function obj = ParallelSimulator()
            obj.data = MatStackedData();
            obj.attachSimulationFun();
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
            paramNums = nan(1, N);
            for n = 1:N
                paramNums(n) = numel(varargin{n});
            end
            obj.totalSimNum = prod(paramNums);
            
            obj.paramSetList = cell(1, obj.totalSimNum);
            for i = 1:obj.totalSimNum
                subs = cell(1, N);
                [subs{:}] = ind2sub(paramNums, i);
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
            % output of the simulationFun should be simulation data with
            % the type of structure.
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
                fprintf("[%d/%d] Simulation has been finished.\n",...
                    doneSimNum, totalSimNum_);
            end
            
            fprintf("Total %d number of cases will be simulated. \n", totalSimNum_)
            tic
            tempData = cell(1, totalSimNum_);
            parfor (i = 1:totalSimNum_, numWorkers)
                paramSet = obj.paramSetList{i};
                tempData{i} = obj.simulationFun(i, paramSet{:});
                send(dataQueue, i);
            end
            elapsedTime = toc;
            fprintf("The total elapsed time: %.2f [s] \n", elapsedTime);
            fprintf("The average time taken for each simulation: %.2f [s] \n",...
                elapsedTime/totalSimNum_);
            
            if ~isempty(tempData{1})
                fields = fieldnames(tempData{1});
                obj.data.setVarNames(fields{:});
                for i = 1:obj.totalSimNum
                    simData = struct2cell(tempData{i});
                    obj.data.append(simData{:});
                end
            end
            delete(gcp('nocreate'))
        end
        
        function out = getDataByVarNames(obj, varargin)
            out = obj.data.matValuesByVarNames(varargin{:});
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
            obj.data.save(filePath);
        end
        
        % to be implemented
        function model = simulateModel(obj, i)
            % implement this method if needed
            fprintf("Attach a modelGeneratingFun or implement generateModel method! \n")
        end
    end
end
        