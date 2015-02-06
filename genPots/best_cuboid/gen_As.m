function gen_As()
data_globals;

disp('Data preparing...');
split = load(SPLIT_FILE);
train = split.train;
val = split.val;
test = split.test;
dataset = [train; val; test];

fncls = load(CLASS_FINAL);

As = cell(1449, 1);
Preps = cell(1449, 1);
for i_set = 1:numel(dataset)
    i_sce = dataset(i_set);
    if mod(i_set, 100) == 0
        fprintf('%d Processed.\n', i_set);
    end

    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    info = load(info_file);
    if isempty(info.descriptions)
        error('info.descriptions == []');
    end
    
    gt_file = fullfile(GTS_DIR, sprintf('gt%04d.mat', i_sce));
    if exist(gt_file, 'file')
        gt = load(gt_file);
    else
        gt = [];
    end
    
    nouns = info.descriptions.noun_final;  
    preps = info.descriptions(1).prep;
    num_nouns = numel(nouns);
    num_preps = size(preps,1);
    sentences = info.descriptions.sentences;
    segs = info.seg;
    obj_ids = info.descriptions.obj_id;
    map_nouns = [];
    pronoun = [];
    i_a = 1;
    
    for i_nouns = 1:num_nouns
        noun = nouns(i_nouns);
        A = noun;
        A.pred_class = A.class;
        A.pred_class_id = ['o', num2str(A.class_id_final)];
        id = noun.id;
        posi = {};
        for i_prep = 1:num_preps
            prep = preps(i_prep, :);
            if isequal(id, prep{1}(1:2))
                temp = [prep{2}, ' ', sentences{prep{3}(1)}{prep{3}(2)}];
                posi = [posi, temp]; %#ok<AGROW>
            end
        end
        A.posi = posi;
        id_word = noun.id_word;
        try
            if isempty(obj_ids{id_word})
                o_id = [];
            else
                o_id = str2num(obj_ids{id_word});
            end
        catch %#ok<CTCH>
            o_id = [];
        end
        
        A.obj_id = o_id;
        check_o_id = o_id <= numel(segs);
        A.segs = segs(o_id(check_o_id));
        
        mask = zeros(480, 640);
        for i_seg = 1:numel(A.segs)
            seg = A.segs{i_seg};
            mask = mask + roipoly(zeros(480, 640), seg(:, 1), seg(:, 2));
        end
        mask = mask > 0;
        A.union = mask;
        
        if ~isempty(gt)
            noun_gt = gt.noun{gt.findnoun(id(1), id(2))};
            A.gt_class = noun_gt.cls;
            A.gt_adj = noun_gt.adj;
            A.of_interest = ismember(noun_gt.cls, fncls.classes) && noun_gt.isnoun;
        end
        
        if strcmp(noun.class, 'pronoun')
            if isempty(A.coref)
                continue;
            end
            co = A.coref(1, :);
            noun_pred_co = info.descriptions.class_instance_map{co(1), co(2), 1};
            if isempty(noun_pred_co)
                continue;
            end
            mohit_class = info.descriptions.class(noun_pred_co{1}).name;
            ia = ismember(mohit_class, fncls.classes);
            if ~ia
                continue;
            end
            A.pred_class = mohit_class;
            [~, pred_class_id] = ismember(mohit_class, fncls.classes);
            A.pred_class_id = ['o', num2str(pred_class_id)];
            if ~isempty(gt)
                if isempty(noun_gt.co)
                    A.gt_class = 'background';
                    A.of_interest = 0;
                else
                    id_co = noun_gt.co(1,1:2);
                    noun_gt_co = gt.noun{gt.findnoun(id_co(1), id_co(2))};
                    A.gt_class = noun_gt_co.cls;
                    A.of_interest = ismember(A.gt_class, fncls.classes) ...
                        && noun_gt_co.isnoun && noun_gt.isnoun;
                end
            end
            pronoun = [pronoun; [i_nouns, i_a]]; %#ok<AGROW>
        else
            map_nouns = [map_nouns; [noun.id, i_a]]; %#ok<AGROW>
        end
        
        As{i_sce} = [As{i_sce}, A];
        i_a = i_a + 1;
    end    
    
    for i_pros = 1:size(pronoun, 1)
        i_a = pronoun(i_pros, 2);
        a = As{i_sce}(i_a);
        coref_a = [];
        
        if ~isempty(gt)
            gt_id = gt.findnoun(a.id(1), a.id(2));
            noun = gt.noun{gt_id};
            ids_coref = noun.co;
            mask = zeros(480, 640);
            segs = {};
            for i_id = 1:size(ids_coref, 1)
                id_coref = ids_coref(i_id, 1:2);
                [ia, ib] = ismember(id_coref, map_nouns(:,1:2), 'rows');
                if ia
                    iaa = map_nouns(ib, 3);
                    a_co = As{i_sce}(iaa);
                    coref_a = [coref_a; iaa]; %#ok<AGROW>
                    mask = a_co.union + mask;
                    segs = [segs, a_co.segs]; %#ok<AGROW>
                end
            end
            mask = mask > 0;
            As{i_sce}(i_a).union = mask;
            As{i_sce}(i_a).segs = segs;
            As{i_sce}(i_a).coref_a = coref_a;
        end
    end
    num_preps = numel(PREP_LIST);  %#ok<*USENS>
    Preps{i_sce} = cell(num_preps, 1);
    parse_prep = info.descriptions.prep;
    num_pprep = size(parse_prep, 1);
    for i_prep = 1:num_preps
        if isempty(map_nouns)
            continue;
        end
        for i_pprep = 1:num_pprep
            pprep = parse_prep(i_pprep, :);
            if isempty(pprep{1}) || isempty(pprep{2}) || isempty(pprep{3})
                continue;
            end
            try
            [ia1, ib1] = ismember(pprep{1}(1:2), map_nouns(:, 1:2), 'rows');
            catch
                a = 1;
            end
            [ia2, ib2] = ismember(pprep{3}(1:2), map_nouns(:, 1:2), 'rows');
            if ismember(pprep{2}, PREP_LIST{i_prep}) && ia1 && ia2
                pairwise = [map_nouns(ib1, 3), map_nouns(ib2, 3)];
                Preps{i_sce}{i_prep} = [Preps{i_sce}{i_prep}; pairwise];
            end
        end
    end
end
if ~exist(A_CUBOID_DIR, 'dir')
    mkdir(A_CUBOID_DIR);
end
save(AS_FILE, 'As', 'Preps');