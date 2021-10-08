classdef EngKinematics < handle
    properties
        vehicle1
        vehicle2
    end
    
    properties(Dependent)
        relPos
        relVel
        range
        losVector
        losAngle
        losRate
        closingSpeed
    end
    methods
        function obj = EngKinematics(vehicle1, vehicle2)
            obj.vehicle1 = vehicle1;
            obj.vehicle2 = vehicle2;
        end
        
        function p_r = get.relPos(obj)
            p_r = obj.vehicle2.pos(:) - obj.vehicle1.pos(:);
        end
        
        function v_r = get.relVel(obj)
            v_r = obj.vehicle2.vel(:) - obj.vehicle1.vel(:);
        end
        
        function r = get.range(obj)
            r = norm(obj.relPos);
        end
        
        function out = get.losVector(obj)
            relPos_ = obj.relPos;
            if norm(relPos_) < 0.1
                out = zeros(size(relPos_));
                return
            end
            out = relPos_ / norm(relPos_);
        end
        
        function out = get.losAngle(obj)
            los = obj.losVector;
            
            if numel(los) == 2
                out = atan2(los(2), los(1));
                return
            end
            losN = los(1);
            losE = los(2);
            losD = los(3);
            azim = atan2(losE, losN);
            elev = atan2(-losD, norm(los(2:3)));
            out = [azim; elev];
        end
        
        function omega = get.losRate(obj)
            p_r = obj.vehicle2.pos(:) - obj.vehicle1.pos(:);
            v_r = obj.vehicle2.vel(:) - obj.vehicle1.vel(:);
            los = p_r/norm(p_r);
            
            if numel(v_r) == 2
                los = [los; 0];
                v_r = [v_r; 0];
                omega = cross(los, v_r)/norm(p_r);
                omega = omega(3);
                return
            end
            omega = cross(los, v_r)/norm(p_r);
        end
        
        function V_c = get.closingSpeed(obj)
            V_c = norm(obj.relVel);
        end
    end
end