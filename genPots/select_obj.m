function [objs_s, use_id] = select_obj(objs, fcls, isfinal)
objs_s = [];
use_id = [];
for i_objs = 1:numel(objs)
    obj = objs(i_objs);
    if obj.label <= 0
        label = 0;
    else
        if isfinal
            label = obj.label;
        else
            label = fcls.reduced_to_final(obj.label);
        end
            
    end
    if isfinal || label > 0
        if isfinal
            assert(obj.has_cube && ~obj.diff && ~obj.badannot);
        else
            if obj.diff || obj.badannot || ~obj.has_cube
                continue;
            end    
        end
        objs_s = [objs_s, obj];
        use_id = [use_id, i_objs];
    end
end
