classdef ClosedLoopLinSystem < SimObject
    properties
        linSystem
        K
    end
    methods
        function obj = ClosedLoopLinSystem()
            obj = obj@SimObject();

            zeta = 0.1;
            omega = 1;
            A = [0, 1; -omega^2, -2*zeta*omega];
            B = [0; omega^2];
            derivFun = @(x, u) {A*x + B*u};

            obj.linSystem = DynSystem({[0; 1]}, {'x'}, {'u'}, derivFun, [], 'linSystem');

            Q = diag([1, 1]);
            R = 1;
            obj.K = lqr(A, B, Q, R);

            obj.addSimObjs({obj.linSystem});
        end
    end
    methods(Access=protected)
        % implement
        function out = forward_(obj)
            x = obj.linSystem.state(1);
            u_lqr = -obj.K*x;
            obj.linSystem.forward(u_lqr);
            
            out = [];
        end
    end
end