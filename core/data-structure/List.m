classdef List < handle
    properties(Constant)
        EXPANSION_RATIO = 1.4;
    end
    properties
        items
        allocatedSize
        dataNum
    end
    methods
        function obj = List(items, allocatedSize)
            arguments
                items = {}
                allocatedSize = 100;
            end

            if isa(items, 'numeric') || isa(items, 'logical')
                items = shiftdim(items, ndims(items) - 1);
                temp = cell(size(items, 1), 1);

                shape = size(items);
                if numel(shape) - 1 == 1
                    for i = 1:numel(temp)
                        temp{i} = items(i, :).';
                    end
                else
                    for i = 1:numel(temp)
                        temp{i} = reshape(items(i, :), shape(2:end));
                    end
                end
                items = temp;
            end
            allocatedSize = max(numel(items), allocatedSize);
            
            obj.items = cell(allocatedSize, 1);
            obj.allocatedSize = allocatedSize;
            obj.dataNum = numel(items);
        end
        
        function append(obj, item)
            if obj.dataNum >= numel(obj.items)
                obj.expandAllocatedSize();
            end
            obj.items{obj.dataNum + 1} = item;
            obj.dataNum = obj.dataNum + 1;
        end
        
        function expandAllocatedSize(obj)
            newSize = ceil(List.EXPANSION_RATIO*obj.allocatedSize);
            obj.items = [obj.items; cell(newSize - numel(obj.items), 1)];
            obj.allocatedSize = numel(obj.items);
        end
        
        function out = numel(obj)
            out = obj.dataNum;
        end

        function out = isempty(obj)
            out = (obj.dataNum == 0);
        end

        function out = contains(obj, item)
            if isa(item, 'handle')
                compare = @(x) eq(x, item);
            else
                compare = @(x) isequal(x, item);
            end
            out = any(cellfun(compare, obj.toCell()));
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

        function out = toCell(obj)
            out = obj.items(1:obj.dataNum);
        end
        
        function out = toArray(obj)
            assert(isa(obj.items{1}, 'numeric') || isa(obj.items{1}, 'logical'),...
                "Stored items are not numeric nor logical.")
            shape = size(obj.items{1});
            if shape(end) == 1
                out = cat(numel(shape), obj.items{1:obj.dataNum});
            else
                out = cat(numel(shape) + 1, obj.items{1:obj.dataNum});
            end
        end
        
        function remove(obj, item)
            if isa(item, 'handle')
                compare = @(x) eq(x, item);
            else
                compare = @(x) isequal(x, item);
            end
            compResult = cellfun(compare, obj.toCell());
            index = find(compResult);

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
                for i = 1:numel(newItems)
                    obj.append(newItems{i});
                end
            elseif isa(newItems, 'List')
                for i = 1:numel(newItems)
                    obj.append(newItems.get(i));
                end
            end
        end
        
        function newList = copy(obj)
            newList = List(obj.items(1:obj.dataNum));
        end
    end
end