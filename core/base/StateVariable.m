classdef StateVariable < handle
    properties
        state double
        deriv double
        rk4Buffer cell
        correctionFun
    end
    properties(Dependent)
        shape
    end
    methods
        function obj = StateVariable(state)
            obj.state = toArray(state);
            obj.deriv = zeros(size(state));
            obj.rk4Buffer = cell(4, 1);
        end

        function applyState(obj, state)
            obj.state = toArray(state);
        end

        % property
        function out = get.shape(obj)
            out = size(obj.state);
        end

        function setDeriv(obj, deriv)
            obj.deriv = toArray(deriv);
        end

        function rk4Update1(obj, dt)
            x_0 = obj.state;
            k_1 = obj.deriv;

            obj.rk4Buffer{1} = x_0;
            obj.rk4Buffer{2} = k_1;
            obj.state = x_0 + dt/2*k_1; % x = x0 + dt/2*k1
            if ~isempty(obj.correctionFun)
                obj.state = obj.correctionFun(obj.state);
            end
        end

        function rk4Update2(obj, dt)
            x_0 = obj.rk4Buffer{1};
            k_2 = obj.deriv;

            obj.rk4Buffer{3} = k_2;
            obj.state = x_0 + dt/2*k_2; % x = x0 + dt/2*k2
            if ~isempty(obj.correctionFun)
                obj.state = obj.correctionFun(obj.state);
            end
        end

        function rk4Update3(obj, dt)
            x_0 = obj.rk4Buffer{1};
            k_3 = obj.deriv;

            obj.rk4Buffer{4} = k_3;
            obj.state = x_0 + dt*k_3; % x = x0 + dt*k3
            if ~isempty(obj.correctionFun)
                obj.state = obj.correctionFun(obj.state);
            end
        end

        function rk4Update4(obj, dt)
            [x_0, k_1, k_2, k_3] = obj.rk4Buffer{:};
            k_4 = obj.deriv;

            obj.state = x_0 + dt*(k_1 + 2*k_2 + 2*k_3 + k_4)/6;
            if ~isempty(obj.correctionFun)
                obj.state = obj.correctionFun(obj.state);
            end
        end

        function attachCorrectionFun(obj, correctionFun)
            obj.correctionFun = correctionFun;
        end
    end
end