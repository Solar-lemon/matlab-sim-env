function d = kwargsToDict(varargin)
if isa(varargin{1}, 'dictionary')
    d = varargin{1};
    return
end
keys = varargin(1:2:end);
values = varargin(2:2:end);
if isnumeric(values)
    values = num2cell(values);
end
d = dictionary(keys, values);
end
