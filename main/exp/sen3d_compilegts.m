function GTs = sen3d_compilegts(objty)
%SEN3D_COMPILEGTS Compiles ground-truth into a convenient file
%
%   SEN3D_COMPILEGTS(threshold)
%
data_globals;

final_cls = load(CLASS_FINAL);
reduced_to_final = final_cls.reduced_to_final;

n = 1449;

GTs = cell(n, 1);
tn_all = 0;
tn_use = 0;

is_final = 1;
if strcmpi(objty, 'gt') 
    is_final = 0;
end
    

for i = 1 : n
    objs = load(fullfile(OBJ_DIR, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    nobjs = numel(objs);
    
    gt = struct( ...
        'nobjs', nobjs, ...
        'final_label', zeros(1, nobjs), ...
        'use', true(1, nobjs), ...
        'bndbox', zeros(nobjs, 4));        
    
    for j = 1 : nobjs
        o = objs(j);
        
        if o.label > 0
            if is_final
                gt.final_label(j) = o.label;
            else
                gt.final_label(j) = reduced_to_final(o.label);
            end
        end
        
        if gt.final_label(j) <= 0 || o.diff || o.badannot || ~o.has_cube
            gt.use(j) = 0;
        end
        
        gt.bndbox(j,:) = o.bndbox; 
    end   
    
    tn_all = tn_all + gt.nobjs;
    tn_use = tn_use + nnz(gt.use);
    
    GTs{i} = gt;
end

fprintf('Use %d / %d\n', tn_use, tn_all);

save(GTS_FILE, 'GTs', 'tn_use', 'tn_all');
