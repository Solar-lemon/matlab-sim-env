classdef List < handle
    properties
        items
        allocatedSize
        dataNum
    end
    methods
        function obj = List(items)
            if nargin < 1
                obj.items = cell(1, 1000);
                obj.allocatedSize = 1000;
                obj.dataNum = 0;
                return
            end
            obj.items = items;
            obj.allocatedSize = numel(items);
            obj.dataNum = numel(items);
        end
        
        function append(obj, item)
            if obj.dataNum + 1 > numel(obj.items)
                obj.doubleAllocatedSize();
            end
            obj.items{1, obj.dataNum + 1} = item;
            obj.dataNum = obj.dataNum + 1;
        end
        
        function doubleAllocatedSize(obj)
            obj.items = [obj.items, cell(1, obj.dataNum)];
            obj.allocatedSize = numel(obj.items);
        end
        
        function out = numel(obj)
            out = obj.dataNum;
        end
        
        function out = get(obj, index)
            if nargin < 2
                index = 1:obj.dataNum;
            end
            assert(all(index >= 0 & index <= obj.dataNum),...
                "list index out of range")
            
            if numel(index) == 1
                out = obj.items{index};
            else
                out = List(obj.items(index));
            end
        end
        
        function out = toMatrix(obj)
            assert(isa(obj.items{1}, 'numeric'),...
                "Stored items are not numeric.")
            shape = size(obj.items{1});
            if shape(end) == 1
                out = cat(numel(shape), obj.items{1, :});
            else
                out = cat(numel(shape) + 1, obj.items{1, :});
            end
        end
        
        function remove(obj, value)
            index = [];
            if isa(value, 'numeric')
                for i = 1:obj.dataNum
                    if all(obj.items{i} == value)
                        index = i;
                        break
                    end
                end
            elseif isa(value, 'char') || isa(value, 'string')
                index = find(strcmp(obj.items, value));
            end
            if isempty(index)
                return
            end
            obj.pop(index);
        end
        
        function pop(obj, index)
            obj.items(index:end - 1) = obj.items(index + 1:end);
            obj.dataNum = obj.dataNum - 1;
        end
        
        function extend(obj, newItems)
            if isa(newItems, 'cell')
                for i = 1:numel(cell)
                    obj.append(newItems{i});
                end
                return
            end
            if isa(newItems, 'List')
                for i = 1:numel(newItems)
                    obj.append(newItems.get(i));
                end
                return
            end
        end
        
        function newList = copy(obj)
            newList = List(obj.items);
        end
    end
end
        