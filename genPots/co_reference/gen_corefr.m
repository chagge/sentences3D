function gen_corefr(cfg)
switch lower(cfg)
    case '4'
        objty = 'gt';
    case '5'
        objty = 'gt';
    case '6'
        objty = 'gt';
    case 'r4'
        objty = 'nn15';
    case 'r5'
        objty = 'nn15';
    case 'r6'
        objty = 'nn15';
    case 'r6_a'
        objty = 'nn15';
    otherwise
        error('Unknown object type %s', cfg);
end
data_globals;
dir = fullfile(DATADIR, 'predict_gold', [objty, '-', cfg]);
if ~exist(dir, 'dir')
    mkdir(dir);
else
    unix(sprintf('rm -r %s', dir));
    mkdir(dir);
end
result_file = fullfile(DATADIR, 'result', cfg, 'C1.0e-02', 'results_test.a0.mat');
result = load(result_file);
results = result.results;
As = load(AS_FILE);
As = As.As;
best_cuboid = load(BEST_CUBOID_POTS_FILE);
lists = best_cuboid.list;
split = load(SPLIT_FILE);
for i_set = 1:numel(split.test)
    if mod(i_set, 20) == 0
        fprintf('doing %d\n', i_set);
    end
    i_sce = split.test(i_set);
    file = fullfile(dir, sprintf('%04d.txt.pred', i_sce));
    fid = fopen(file, 'w+');
    as = As{i_sce};
    list = lists{i_sce};
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    info = load(info_file);
    predict = results(i_set).a_labels;
    num_obj = max(predict);
    corefs = cell(num_obj, 1);
    for i_obj = 1:num_obj
        id = find(predict == i_obj);
        if isempty(id)
            continue;
        end
        for i_id = 1:numel(id)
            i_a = id(i_id);
            a = as(list(i_a));
            corefs{i_obj} = [corefs{i_obj}; a.id];
        end
        corefs{i_obj} = unique(corefs{i_obj}, 'rows');
    end
    for i_co = 1:numel(corefs)
        coref = corefs{i_co};
        num_coref = size(coref, 1);
        if num_coref < 2
            continue;
        end
        sco = coref(:,1) * 100 + coref(:,2);
        [~, i] = sort(sco);
        fprintf(fid, 'Coreference set:\n');
        word_key = coref(i(1), :);
        text_key = info.descriptions.sentences{word_key(1)}{word_key(2)};
        for i_words = 2:num_coref
            word_co = coref(i(i_words), :);
            text_co = info.descriptions.sentences{word_co(1)}{word_co(2)};
            fprintf(fid, '	(%d,%d,[%d,%d)) -> ',word_co(1), word_co(2), word_co(2), word_co(2)+1);
            fprintf(fid, '(%d,%d,[%d,%d)), ', word_key(1), word_key(2), word_key(2), word_key(2)+1);
            fprintf(fid, 'that is: "%s" -> "%s"\n',text_co, text_key);
        end
    end
    fclose(fid);
end