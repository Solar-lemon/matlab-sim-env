function [keys, values] = unpackKwargs(varargin)
if isa(varargin{1}, 'dictionary')
    keys = varargin{1}.keys();
    values = varargin{1}.values();

    if ~iscell(values)
        temp = cell(numel(values), 1);
        for i = 1:numel(values)
            temp{i} = values(i);
        end
        values = temp;
    end
    return
end
keys = varargin(1:2:end);
values = varargin(2:2:end);
end