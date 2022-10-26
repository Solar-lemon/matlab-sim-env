function kwargs = dictToKwargs(d)
if numEntries(d) == 0
    kwargs = {};
    return
end
keys = d.keys();
values = d.values();
if isnumeric(values)
    values = num2cell(values);
end
kwargs = cell(2*numel(keys), 1);
for i = 1:numel(keys)
    kwargs{2*i - 1} = keys{i};
    kwargs{2*i} = values{i};
end
end