classdef Simulator < handle
    properties
        time
        system
        stateNum
        saveHistory
    end
    methods
        function obj = Simulator(system, saveHistory)
            if nargin < 2
                saveHistory = true;
            end
            obj.time = 0;
            obj.system = system;
            obj.stateNum = system.stateNum;
            obj.saveHistory = saveHistory;
        end
        
        function step(obj, dt, varargin)
            obj.system.forward();
            obj.system.saveHistory();
            
            % remember initial state values
            t0 = obj.time;
            y0 = obj.system.state;
            
            k1 = obj.system.stateDeriv();
            k2 = obj.system.stateDeriv(y0 + dt/2*k1, t0 + dt/2);
            k3 = obj.system.stateDeriv(y0 + dt/2*k2, t0 + dt/2);
            k4 = obj.system.stateDeriv(y0 + dt*k3, t0 + dt);
            
            % update time and states
            t = t0 + dt;
            y = y0 + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
            obj.system.applyTime(t);
            obj.system.applyState(y);
            obj.time = t;
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for Simulator class == \n')
            
            mySystem = MySystem();
            saveHistory = true;
            simulator = Simulator(mySystem, saveHistory);
            dt = 0.01;
            
            tic
            for i = 1:1000
                simulator.step(dt);
            end
            elapsedTime = toc;
            
            fprintf('Initial state of the system: \n')
            disp(mySystem.state)
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            fprintf('State of the system after 1[s]: \n')
            disp(mySystem.state)
            
            mySystem.plot();
        end
    end
end