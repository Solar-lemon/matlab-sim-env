classdef Simulator < handle
    properties
        system
        stateNum
        inValues
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
            obj.system.forwardWrapper(obj.inValues);
            obj.system.finishLogging();
        end
        
        function step(obj, dt, varargin)
            t0 = obj.system.time;
            
            obj.system.rk4Update1(t0, dt, varargin);
            obj.system.rk4Update2(t0, dt, varargin);
            obj.system.rk4Update3(t0, dt, varargin);
            obj.system.rk4Update4(t0, dt, varargin);
            
            obj.inValues = varargin;
        end
        
        function propagate(obj, dt, time, saveHistory, varargin)
            if nargin < 4 || isempty(saveHistory)
                saveHistory = false;
            end
            
            iterNum = round(time/dt);
            if saveHistory
                obj.startLogging(dt);
            end
            for i = 1:iterNum
                t0 = obj.system.time;
                
                obj.system.rk4Update1(t0, dt, varargin);
                obj.system.rk4Update2(t0, dt, varargin);
                obj.system.rk4Update3(t0, dt, varargin);
                obj.system.rk4Update4(t0, dt, varargin);
                
                toStop = obj.system.checkStopCondition();
                if toStop
                    break
                end
            end
            
            obj.inValues = varargin;
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