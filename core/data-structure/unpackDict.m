function kwargs = unpackDict(d)
arguments
    d dictionary
end
keys = d.keys();
values = d.values();

kwargs = cell(2*numel(keys), 1);
if iscell(values)
    for i = 1:numel(keys)
        kwargs{2*i - 1} = keys{i};
        kwargs{2*i} = values{i};
    end
else
    for i = 1:numel(keys)
        kwargs{2*i - 1} = keys{i};
        kwargs{2*i} = values(i);
    end
end