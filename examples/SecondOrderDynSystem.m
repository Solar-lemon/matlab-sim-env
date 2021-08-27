classdef SecondOrderDynSystem < DynSystem
    properties
        zeta
        omega
        A
        B
    end
    methods
        function obj = SecondOrderDynSystem(initialState, zeta, omega)
            obj = obj@DynSystem(initialState);
            obj.zeta = zeta;
            obj.omega = omega;
            obj.A = [...
                0, 1;
                -omega^2, -2*zeta*omega];
            obj.B = [0; omega^2];
        end
        
        % override
        function out = derivative(obj, x, u)
            out = obj.A*x + obj.B*u;
        end
        
        % override
        function out = output(obj)
            out = obj.state(1);
        end
        
        % override
        function varToLog = log(obj, u)
            e_r = obj.output() - u; % e_r = y - r
            varToLog = {e_r};
        end
        
        function errorFig = plotError(obj)
            time = obj.history{1};
            e_r = obj.history{4};
            
            errorFig = figure();
            errorFig.Name = "Error";
            hold on
            plot(time, e_r, 'DisplayName', 'y - r')
            xlabel('Time [s]')
            ylabel('Error')
            grid on
            box on
            legend()
        end
    end
end