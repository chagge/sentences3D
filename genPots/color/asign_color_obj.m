function asign_color_obj(objty)
data_globals;
best = load(BEST_COLOR_MODELS_FILE);
best = best.best;
fprintf('ADDING COLOR FIELD IN OBJ.');
mkdir(OBJ_C_DIR);
for i = 1:1449
    if mod(i, 10) == 0
        fprintf('doing %d...\n', i);
    end
    file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i));
    if exist(file, 'file')
        continue;
    end
    objs_file = fullfile(OBJ_DIR, sprintf('%04d.mat', i));
    objects = load(objs_file);
    objects = objects.objects;
    num_objs = numel(objects);
    
    for i_obj = 1:num_objs
        obj = objects(i_obj);
        if obj.diff || obj.badannot || ~obj.has_cube
            continue;
        end
        feature = get_color_feature(i, obj.pixels);
        [color_score, ~, ~] = kc_svmpredict(best.models, best.clabels, feature, 1);
        objects(i_obj).color = color_score;
    end
    
    save(file, 'objects');
end
fprintf('\nADD FINISHED.\n');