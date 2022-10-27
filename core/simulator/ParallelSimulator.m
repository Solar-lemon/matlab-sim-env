classdef ParallelSimulator < handle
    properties
        simulationFun
        logger
        name
    end
    methods
        function obj = ParallelSimulator(simulationFun)
            obj.simulationFun = simulationFun;
            obj.logger = Logger();
            obj.name = "parSimulator";
        end
        
        function simulate(obj, paramSets)
            arguments
                obj
                paramSets cell
            end
            pool = gcp;
            numWorkers = pool.NumWorkers;
            dataQueue = parallel.pool.DataQueue;
            afterEach(dataQueue, @showProgress);
            
            totalSimNum = numel(paramSets);
            doneSimNum = 0;
            function showProgress(result)
                doneSimNum = doneSimNum + 1;
                fprintf("[%s] [%d/%d] Simulation has been finished.\n",...
                    obj.name, doneSimNum, totalSimNum);
                obj.logger.append(result.keys, result.values);
            end
            
            fprintf("[%s] Total %d number of cases will be simulated. \n", ...
                obj.name, totalSimNum)
            fprintf("[%s] Simulating... \n", obj.name)

            tic
            keySets = cell(1, totalSimNum);
            valueSets = cell(1, totalSimNum);

            parfor (i = 1:totalSimNum, numWorkers)
                params = paramSets{i};
                result = obj.simulationFun(params{:});
                send(dataQueue, result);
            end

            elapsedTime = toc;
            fprintf("[%s] The total elapsed time: %.2f [s] \n", obj.name, elapsedTime);
            fprintf("[%s] The average time taken for each simulation: %.2f [s] \n",...
                obj.name, elapsedTime/totalSimNum);

            delete(gcp('nocreate'))
        end
        
        function out = get(obj, varargin)
            out = cell(size(varargin));
            for i = 1:numel(out)
                out{i} = obj.logger.get(varargin{i});
            end
        end
        
        function save(obj, filename, dataGroup)
            arguments
                obj
                filename
                dataGroup = ''
            end
            if isempty(filename)
                filename = './data/parSim.hdf5';
            end
            obj.logger.save(filename, dataGroup);
        end
    end
end
        