classdef Simulator < handle
    properties
        system
        stateNum
    end
    methods
        function obj = Simulator(system)
            obj.system = system;
            obj.stateNum = system.stateNum;
        end
        
        function step(obj, dt, saveHistory, varargin)
            if nargin < 3 || isempty(saveHistory)
                saveHistory = true;
            end
            obj.system.forward(varargin{:});
            if saveHistory
                obj.system.saveHistory();
            end
            
            % remember initial state values
            t0 = obj.system.time;
            y0 = obj.system.state;
            
            k1 = obj.system.stateDeriv([], [], varargin{:});
            k2 = obj.system.stateDeriv(y0 + dt/2*k1, t0 + dt/2, varargin{:});
            k3 = obj.system.stateDeriv(y0 + dt/2*k2, t0 + dt/2, varargin{:});
            k4 = obj.system.stateDeriv(y0 + dt*k3, t0 + dt, varargin{:});
            
            % update time and states
            t = t0 + dt;
            y = y0 + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
            obj.system.applyTime(t);
            obj.system.applyState(y);
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = true;
            end
            iterNum = round(time/dt);
            for i = 1:iterNum
                step(obj, dt, saveHistory, varargin{:});
            end
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for Simulator class == \n')
            fprintf('Simulating the system... \n')
            
            mySystem = MySystem(); % Refer to MySystem class
            initialState = mySystem.state;
            simulator = Simulator(mySystem);
            
            dt = 0.01;
            finalTime = 10;
            saveHistory = true;
            
            tic
            simulator.propagate(dt, finalTime, saveHistory);
            elapsedTime = toc;
            
            fprintf('Initial state of the system: \n')
            disp(initialState)
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            fprintf('State of the system after 10[s]: \n')
            disp(mySystem.state)
            
            mySystem.plot();
        end
    end
end