classdef Simulator < handle
    properties
        initialized = false;
        system
        stateNum
    end
    methods
        function obj = Simulator(system)
            obj.system = system;
            obj.stateNum = system.stateNum;
        end
        
        function startLogging(obj, interval)
            obj.system.startLogging(interval);
        end
        
        function finishLogging(obj)
            obj.system.finishLogging();
            obj.system.saveHistory();
        end
        
        function step(obj, dt, varargin)
            if ~obj.initialized
                obj.system.forward(varargin{:});
                obj.initialized = true;
            end
            
            % remember initial state values
            t0 = obj.system.time;
            y0 = obj.system.state;
            
            odeFun = @(y, t) obj.system.stateDeriv(y, t, varargin{:});
            
            k1 = odeFun(y0, t0);
            k2 = odeFun(y0 + dt/2*k1, t0 + dt/2);
            k3 = odeFun(y0 + dt/2*k2, t0 + dt/2);
            k4 = odeFun(y0 + (dt - 10*eps(t0))*k3, t0 + dt - 10*eps(t0));
            
            % update time and states
            t = t0 + dt;
            y = y0 + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
            obj.system.applyTime(t);
            obj.system.applyState(y);
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = false;
            end
            
            if saveHistory
                obj.startLogging(dt);
            end
            if ~obj.initialized
                obj.system.forward(varargin{:});
                obj.initialized = true;
            end
            
            iterNum = round(time/dt);
            
            t = obj.system.time;
            y = obj.system.state;
            
            odeFun = @(y, t) obj.system.stateDeriv(y, t, varargin{:});
            for i = 1:iterNum
                k1 = odeFun(y, t);
                k2 = odeFun(y + dt/2*k1, t + dt/2);
                k3 = odeFun(y + dt/2*k2, t + dt/2);
                k4 = odeFun(y + (dt - 10*eps(t))*k3, t + dt - 10*eps(t));
                
                % update time and states
                t = t + dt;
                y = y + dt*(k1 + 2*k2 + 2*k3 + k4)/6;
                
                toStop = obj.system.checkStopCondition();
                if toStop
                    break
                end
            end
            obj.system.applyTime(t);
            obj.system.applyState(y);
            
            obj.finishLogging();
        end
    end
    
    methods(Static)
        function test()
            clc
            close all
            
            fprintf('== Test for Simulator class == \n')
            fprintf('Test for propagate method \n')
            fprintf('Simulating the system... \n')
            
            system = ExampleSystem(); % Refer to MySystem class
            initialState = system.state;
            simulator = Simulator(system);
            
            dt = 0.01;
            finalTime = 5;
            saveHistory = true;
            
            tic
            simulator.propagate(dt, finalTime, saveHistory);
            simulator.propagate(dt, finalTime, saveHistory);
            elapsedTime = toc;
            
            fprintf('Initial state of the system: \n')
            disp(initialState)
            fprintf('Elapsed time: %.2f [s] \n', elapsedTime);
            fprintf('State of the system after 10[s]: \n\n')
            disp(system.state)
            
            system.linearSystem.plot();
            
            fprintf('Test for step method \n')
            system.reset();
            simulator.startLogging(0.01);
            for i = 1:1000
                simulator.step(0.01);
            end
            simulator.finishLogging();
            system.linearSystem.plot();
        end
    end
end