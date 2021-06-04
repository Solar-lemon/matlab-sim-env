classdef MySystem < SequentialSystem
    properties
        linearSystem
    end
    methods
        function obj = MySystem()
            obj = obj@SequentialSystem();
            
            omega = 1;
            zeta  = 0.5;
            A = [0, 1;
                -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            obj.linearSystem = DynSystem([0; 1], @(x, u) A*x + B*u);
            obj.attachDynSystems({obj.linearSystem});
        end
        
        function forward(obj)
            u_step = 1;
            obj.linearSystem.forward(u_step);
        end
    end
end