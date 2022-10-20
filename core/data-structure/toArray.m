function out = toArray(data)
if iscell(data)
    out = cell2mat(data);
    return
end
out = data;
end