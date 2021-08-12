classdef SecondOrderDynFun < LinearDynFun
    properties
        zeta
        omega
    end
    methods
        function obj = SecondOrderDynFun(zeta, omega)
            A = [...
                0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            obj = obj@LinearDynFun(A, B);
            obj.zeta = zeta;
            obj.omega = omega;
        end
        
        % override
        function out = forward(obj, x, u)
            assert(length(x) == 2, 'The dimension of the state should be 2.')
            assert(isscalar(u), 'The dimension of the input should be 1.')
            out = forward@LinearDynFun(obj, x, u);
        end
    end
    
    methods(Static)
        function test()
            fprintf('== Test for SecondOrderDynFun == \n')
            zeta = 0.5;
            omega = 1;
            system = DynSystem([0; 0], SecondOrderDynFun(zeta, omega));
            simulator = Simulator(system);
            
            u_step = 1;
            simulator.propagate(0.01, 10, true, u_step);
            
            [timeList, stateList, inputList] = system.history{:};
            figure();
            hold on
            plot(timeList, inputList, '-', 'DisplayName', 'Reference')
            plot(timeList, stateList(1, :), '--', 'DisplayName', 'Actual')
            xlabel('Time')
            ylabel('Value')
            grid on
            box on
            legend()
        end
    end
end