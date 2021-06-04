classdef Simulator < handle
    properties
        time
        system
        stateNum
    end
    methods
        function obj = Simulator(system)
            obj.time = 0;
            obj.system = system;
            obj.stateNum = system.stateNum;
        end
        
        function step(obj, dt, varargin)
            % remember initial state values
            t0 = obj.time;
            y0 = obj.system.state;
            
            k1 = obj.system.stateDeriv(y0, t0);
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
            simulator = Simulator(mySystem);
            dt = 0.1;
            
            fprintf('Initial state of the system: \n')
            disp(mySystem.state)
            for i = 1:100
                simulator.step(dt);
            end
            fprintf('State of the system after 1[s]: \n')
            disp(mySystem.state)
        end
    end
end