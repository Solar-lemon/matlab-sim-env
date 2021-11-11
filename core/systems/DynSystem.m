classdef DynSystem < TimeVaryingDynSystem
    properties
        
    end
    methods
        function obj = DynSystem(initialState, derivFun, outputFun)
            if nargin < 3 || isempty(outputFun)
                outputFun = @(x) x;
            end
            if nargin < 2
                derivFun = [];
            end
            obj = obj@TimeVaryingDynSystem(initialState, derivFun, outputFun);
            obj.name = 'dynSystem';
        end
        
        % to be implemented
        function out = derivative(obj, state, varargin)
            assert(~isempty(obj.derivFun),...
                "Attach a derivFun or implement the derivative method!")
            out = obj.derivFun(state, varargin{:});
        end
        
        % override
        function out = forward(obj, varargin)
            % varargin: {input1, ..., inputM}
            deriv = obj.derivative(...
                obj.stateVarList.get(1).state, varargin{:});
            obj.stateVarList.get(1).forward(deriv);
            
            if obj.logTimer.isEvent
                obj.logger.append(...
                    {'time', 'state'},...
                    {obj.simClock.time, obj.stateVarList.get(1).state});
                inputKeySet = cell(size(varargin));
                for i = 1:numel(varargin)
                    inputKeySet{i} = ['u_', num2str(i)];
                end
                obj.logger.append(inputKeySet, varargin);
            end
            
            out = obj.output;
        end
        
        % override
        function out = output(obj)
            % outputFun: function_handle or BaseFunction
            % outputFun(state)
            out = obj.outputFun(obj.stateVarList.get(1).state);
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for DynSystem == \n')
            dt = 0.01;
            simClock = SimClock();
            logTimer = Timer(dt);
            logTimer.attachSimClock(simClock);
            logTimer.turnOn();
            
            A = [0, 1;
                -1, -1];
            B = [0; 1];
            derivFun = @(x, u) A*x + B*u;
            model = DynSystem([0; 1], derivFun);
            model.attachSimClock(simClock);
            model.attachLogTimer(logTimer);
            
            tic
            u_step = 1;
            model.propagate(0.01, 10, u_step);
            elapsedTime = toc;
            
            fprintf('ElapsedTime: %.2f [s] \n', elapsedTime)
            model.plot();
        end
    end
end