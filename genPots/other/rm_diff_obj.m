function rm_diff_obj()
data_globals;

for i = 1:1449
    if mod(i, 100) == 0
        fprintf('processed %d/1449\n', i);
    end
    objs_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i));
    objects = load(objs_file);
    objects = objects.objects;
    num_objs = numel(objects);
    index = [];
    for i_obj = 1:num_objs
        obj = objects(i_obj);
        if obj.diff || obj.badannot || ~obj.has_cube
            continue;
        end
        index = [index, i_obj]; %#ok<AGROW>
    end
    objects = objects(index);  %#ok<NASGU>
    file = fullfile(OBJ_R_DIR, sprintf('%04d.mat', i));
    save(file, 'objects');
end
fprintf('\nADD FINISHED.\n');