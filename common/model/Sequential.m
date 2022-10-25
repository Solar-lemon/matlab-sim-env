classdef Sequential < MultipleSystem
    properties
        objList
        firstObj
        otherObjList
    end
    
    methods
        function obj = Sequential(objList)
            assert(numel(objList) > 0,...
                "[Sequential] Invalid objList")
            if isa(objList, 'cell')
                objList = List(objList);
            end
            obj.objList = objList;
            obj.firstObj = objList.get(1);
            obj.otherObjList = objList.copy();
            obj.otherObjList.pop(1);
            
            obj.attachSimObjects(objList);
        end
        
        % implement
        function out = forward(obj, varargin)
            out = obj.firstObj.forward(varargin{:});
            for i = 1:numel(obj.otherObjList)
                if iscell(out)
                    out = obj.otherObjList{i}.forward(out{:});
                else
                    out = obj.otherObjList{i}.forward(out);
                end
            end
        end
    end
end