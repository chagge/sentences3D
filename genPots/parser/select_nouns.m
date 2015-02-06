function select_nouns()
data_globals;
dict_file = fullfile(DATADIR, 'learned_dict_w.mat');
dest_file = fullfile(DATADIR, 'learned_dict_w_s.mat');
if exist(dest_file, 'file')
    dict_file = dest_file;
end
dict = load(dict_file);
num_objs = numel(dict.obj_dict);
for i_objs = 1:num_objs-1
    index = [];
    fprintf('\nnow for : %s\n', dict.classlist{i_objs});
    objs = dict.obj_dict{i_objs};
    num_obj = numel(objs);
    for i_obj = 1:num_obj
        obj = objs{i_obj};
        yn = input(sprintf('%s \n', obj),'s');
        if strcmp(yn,'stop')
            return;
        end
        if strcmp(yn,'y')
            index = [index, i_obj]; %#ok<AGROW>
        end
    end
    dict.obj_dict{i_objs} = dict.obj_dict{i_objs}(index);
    save(dest_file, '-struct', 'dict');
end
num_sces = numel(dict.sce_dict);
for i_sces = 1:num_sces-1
    index = [];
    fprintf('\nnow for : %s\n', dict.classlist{num_objs + i_sces});
    sces = dict.sce_dict{i_sces};
    num_sce = numel(sces);
    for i_sce = 1:num_sce
        sce = sces{i_sce};
        yn = input(sprintf('%s \n', sce),'s');
        if strcmp(yn,'stop')
            return;
        end
        if strcmp(yn,'y')
            index = [index, i_sce]; %#ok<AGROW>
        end
    end
    dict.sce_dict{i_sces} = dict.sce_dict{i_sces}(index); 
    save(dest_file, '-struct', 'dict');
end