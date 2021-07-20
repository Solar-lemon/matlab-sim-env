classdef PurePNG3dimEngagement < MultipleSystem
    properties
        missile
        target
        kinematics
        purePng
    end
    methods
        function obj = PurePNG3dimEngagement(missileState)
            if nargin < 1
                missileState = [-5E3; -1E3; -5E3; 300; deg2rad(-5); 0];
            end
            obj = obj@MultipleSystem();
            
            obj.missile = Missile3dof(missileState);
            obj.target = StationaryVehicle3dof([0; 0; 0]);
            obj.kinematics = EngKinematics(obj.missile, obj.target);
            obj.purePng = PurePNG3dim(3);
            
            obj.attachDynSystems({obj.missile});
        end
        
        % implement
        function forward(obj)
            v_M = obj.missile.vel;
            omega = obj.kinematics.losRate;
            
            [a_l, a_n] = obj.purePng.forward(v_M, omega);
            obj.missile.forward([0; a_l; a_n]);
        end
        
        function figs = plot(obj)
            figs = cell(1, 1);
            
            figs{1} = figure();
            title('3-dim Flight Path')
            obj.missile.plotPath(figs{1});
            obj.target.plotPos(figs{1});
            
            obj.missile.plot();
        end
    end
end