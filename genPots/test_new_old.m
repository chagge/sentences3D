function test_new_old()
objty = 'gt';
data_globals;

old_as_file = fullfile(DATADIR, 'a_cuboid_working', 'as.mat');
new_as_file = fullfile(DATADIR, 'a_cuboid', 'as.mat');

old = load(old_as_file);
new = load(new_as_file);
split = load(SPLIT_FILE);
set = [split.train; split.test];

for i_set = 1:numel(set)
    i_sce = set(i_set);
    if mod(i_set, 20) == 0
        fprintf('doing %d...\n', i_set);
    end
    nas = new.As{i_sce};
    oas = old.As{i_sce};
    num_old = numel(oas);
    num_new = numel(nas);
    i_old = 1;
    for i_new = 1:num_new
        na = nas(i_new);
        if na.class_id_final == 22
            continue;
        end
        oa = oas(i_old);
        i_old = i_old + 1;
        if ~isequal(na.word, oa.word)
            fprintf('in scene %d, %d a, word is different.\n', i_sce, i_new);
        end
        if ~isequal(na.id, oa.id)
            fprintf('in scene %d, %d a, id is different.\n', i_sce, i_new);
        end
        if ~isequal(na.adj, oa.adj)
            fprintf('in scene %d, %d a, adj is different.\n', i_sce, i_new);
        end
        if ~isequal(na.class, oa.class)
            fprintf('in scene %d, %d a, class is different.\n', i_sce, i_new);
        end
        if ~isequal(na.class_id, oa.class_id)
            fprintf('in scene %d, %d a, class_id is different.\n', i_sce, i_new);
        end
        if ~isequal(na.id_word, oa.id_word)
            fprintf('in scene %d, %d a, id_word is different.\n', i_sce, i_new);
        end
        if ~isequal(na.class_id_final, oa.class_id_final)
            fprintf('in scene %d, %d a, class_id_final is different.\n', i_sce, i_new);
        end
        if ~isequal(na.posi, oa.posi)
            fprintf('in scene %d, %d a, posi is different.\n', i_sce, i_new);
        end
        if ~isequal(na.obj_id, oa.obj_id)
            fprintf('in scene %d, %d a, obj_id is different.\n', i_sce, i_new);
        end
        if ~isequal(na.segs, oa.segs)
            fprintf('in scene %d, %d a, segs is different.\n', i_sce, i_new);
        end
        if ~isequal(na.union, oa.union)
            fprintf('in scene %d, %d a, union is different.\n', i_sce, i_new);
        end
        if ~isequal(na.gt_class, oa.gt_class)
            fprintf('in scene %d, %d a, gt_class is different.\n', i_sce, i_new);
        end
        if ~isequal(na.gt_adj, oa.gt_adj)
            fprintf('in scene %d, %d a, gt_adj is different.\n', i_sce, i_new);
        end
        if ~isequal(na.of_interest, oa.of_interest)
            fprintf('in scene %d, %d a, of_interest is different.\n', i_sce, i_new);
        end
    end
    if i_old-1 ~= num_old
        fprintf('in scene %d, %d a, i_old ~= num_old.\n', i_sce, i_new);
    end
end