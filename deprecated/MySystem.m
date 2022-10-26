classdef MySystem < MultipleSystem
    properties
        % system objects here
        dynSystem1
        dynSystem2
        discSystem1
    end
    methods
        function obj = MySystem()
            obj = obj@MultipleSystem();
            % system definitions here
            obj.dynSystem1 = Something;
            obj.dynSystem2 = Something;
            obj.discSystem1 = Something;
            
            % do not forget to attach dynamic systems and discrete systems
            obj.attachDynSystems({obj.dynSystem1, obj.dynSystem2});
            obj.attachDiscSystems({obj.discSystem1});
        end
        
        % implement
        function y = forward(obj)
            u = fun(obj.time);
            y = obj.discSystem1.forward(u);
            y = obj.dynSystem1.forward(y);
            y = obj.dynSystem2.forward(y);
        end
    end
end