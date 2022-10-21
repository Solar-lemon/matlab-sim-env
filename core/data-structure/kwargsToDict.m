function d = kwargsToDict(varargin)
if isempty(varargin)
    d = [];
    return
end
keys = varargin(1:2:end);
values = varargin(2:2:end);
d = dictionary();

for i = 1:numel(keys)
    if isnumeric(values{i})
        d(keys{i}) = values(i);
    else
        d(keys{i}) = values{i};
    end
end
end