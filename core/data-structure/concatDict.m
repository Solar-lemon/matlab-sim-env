function d = concatDict(d1, d2)
arguments
    d1 dictionary
    d2 dictionary
end

keys = [];
values = [];
if isConfigured(d1)
    keys = [keys; d1.keys()];
    values = [values; d1.values()];
end
if isConfigured(d2)
    keys = [keys; d2.keys()];
    values = [values; d2.values()];
end
d = dictionary(keys, values);