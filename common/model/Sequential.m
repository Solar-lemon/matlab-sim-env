classdef Sequential < SimObject
    properties
        objList
        firstObj
        otherObjList
    end
    
    methods
        function obj = Sequential(objList, interval, name)
            arguments
                objList cell
                interval = -1;
                name = [];
            end
            if numel(objList) == 0
                error('[sequential] Invalid objList')
            end

            obj = obj@SimObject(interval, name);
            obj.objList = objList;
            obj.firstObj = objList{1};
            obj.otherObjList = objList(2:end);

            obj.addSimObjs(objList);
        end
    end
    methods(Access=protected)
        % implement
        function out = forward_(obj, varargin)
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