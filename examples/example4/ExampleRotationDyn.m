classdef ExampleRotationDyn < MultiStateDynSystem
    properties
        % J: inertia [kg*m^2]
        J
    end
    methods
        function obj = ExampleRotationDyn(initialState, J)
            % initial state = {R, omega}
            obj = obj@MultiStateDynSystem(initialState);
            obj.J = J;
            
            function R = rotationCorrectionFun(R)
                % rotation matrix should be orthogonal
                isOrthogonal = Orientations.checkOrthogonality(R);
                if ~isOrthogonal
                    R = Orientations.correctOrthogonality(R);
                end
            end
            obj.stateVarList{1}.attachCorrectionFun(@rotationCorrectionFun);
        end
        
        % override
        function out = derivative(obj, R, omega, tau)
            % R: rotation matrix, 3x3 matrix
            % omega: angular velocity, 3x1 vector
            % tau: control input, 3x1 vector
            R_dot = R*Orientations.hat(omega);
            omega_dot = obj.J\(-cross(omega, obj.J*omega) + tau);
            
            out = {R_dot, omega_dot};
        end
    end
end