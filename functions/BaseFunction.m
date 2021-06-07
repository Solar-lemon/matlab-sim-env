classdef(Abstract) BaseFunction < handle
    properties
        
    end
    methods(Abstract)
        out = forward(obj, varargin)
    end
end