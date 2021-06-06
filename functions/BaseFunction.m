classdef(Abstract) BaseFunction < handle
    properties
        
    end
    methods(Abstract)
        out = evaluate(obj, varargin)
    end
end