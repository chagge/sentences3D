function learn_dictionary(option)
data_globals;

to_use_wordnet = nargin >= 1 && strcmpi(option, 'wordnet');

dict_file = fullfile(DATADIR, 'origin_dict.mat');
split_file = fullfile(DATADIR, 'split.mat');

if to_use_wordnet
    dest_file = fullfile(DATADIR, 'learned_dict_w.mat');
    path = fullfile(ROOT, 'code/parser');
    java_api_path = fullfile(path,'edu.mit.jwi_2.2.6_jdk.jar');
    javaaddpath(java_api_path);
    javaaddpath(path);
else
    dest_file = fullfile(DATADIR, 'learned_dict.mat');
end

dataset = load(split_file);
train = [dataset.train; dataset.val];
num_train = numel(train);

dict = load(dict_file);
classlist = get_clslist(dict); %#ok<NASGU>

for i_set = 1:num_train
    i_sce = train(i_set);
    if mod(i_sce,100)==0
        fprintf('Processing %d/%d...\n',i_set, num_train);
    end
    
    desc_num = 1;
    for idesc = 1:desc_num
        gt_file = fullfile(GTS_DIR, sprintf('gt%04d.mat', i_sce));
        if ~exist(gt_file, 'file')
            continue;
        end
        gt = load(gt_file);
        
        noun = gt.noun;
        num_noun = numel(noun);
        
        for i_noun = 1:num_noun;
            if noun{i_noun}.isnoun
                dict = dict_add(dict, noun{i_noun}, ROOT);
            end
        end
    end
end

if to_use_wordnet
    
    word_used = {};
    num_objcls = numel(dict.obj_dict);
    num_scecls = numel(dict.sce_dict);
    for i_objcls = 1:num_objcls
        word_used = [word_used, dict.obj_dict{i_objcls}]; %#ok<AGROW>
    end
    for i_scecls = 1:num_scecls
        word_used = [word_used, dict.sce_dict{i_scecls}]; %#ok<AGROW>
    end
    
    for i_objcls = 1:num_objcls
        num_word = numel(dict.obj_dict{i_objcls});
        for i_word = 1:num_word;
            % use Wordnet to extend dict
            word = dict.obj_dict{i_objcls}{i_word};
            syn = KC_Syns(word, ROOT);
            synonyms = char(syn.ShowSynSet);
            syn_set = regexp(synonyms, ' ','split');
            add_item = setdiff(syn_set,word_used);
            dict.obj_dict{i_objcls} = [dict.obj_dict{i_objcls}, add_item];
        end
        dict.obj_dict{i_objcls} = unique(dict.obj_dict{i_objcls});
    end

    for i_scecls = 1:num_scecls
        num_word = numel(dict.sce_dict{i_scecls});
        for i_word = 1:num_word;
            % use Wordnet to extend dict
            word = dict.sce_dict{i_scecls}{i_word};
            syn = KC_Syns(word, ROOT);
            synonyms = char(syn.ShowSynSet);
            syn_set = regexp(synonyms, ' ','split');           
            add_item = setdiff(syn_set,word_used);
            dict.sce_dict{i_scecls} = [dict.sce_dict{i_scecls}, add_item];
        end
        dict.sce_dict{i_scecls} = unique(dict.sce_dict{i_scecls});
    end
end

obj_dict = dict.obj_dict; %#ok<NASGU>
sce_dict = dict.sce_dict; %#ok<NASGU>
prep_dict = dict.prep_dict; %#ok<NASGU>
save(dest_file, 'obj_dict', 'sce_dict', 'prep_dict', 'classlist');
        
        
function dict = dict_add(dict, noun, root)
num_objcls = numel(dict.obj_dict);
num_scecls = numel(dict.sce_dict);
classlist = get_clslist(dict);

invalid = {'it','its','they','their','them','one','room'};

cls_id = find(strcmp(classlist, noun.cls));

if cls_id > num_objcls + num_scecls
    error('some error happened with classlist');
end
if isempty(cls_id)
    return;
end
    stem = stemmer(noun.word, root);
    word = char(stem.ShowStem);
if cls_id <= num_objcls
    if isempty(find(strcmp(dict.obj_dict{cls_id}, word),1)) && ...
            isempty(find(strcmp(invalid, word),1))
        dict.obj_dict{cls_id} = [dict.obj_dict{cls_id}, word];
    end
else
    cls_id = cls_id - num_objcls;
    if isempty(find(strcmp(dict.sce_dict{cls_id}, word),1)) && ...
            isempty(find(strcmp(invalid, word),1))
        dict.sce_dict{cls_id} = [dict.sce_dict{cls_id}, word];
    end
end

    
    
function classlist = get_clslist(dict)
num_objcls = numel(dict.obj_dict);
num_scecls = numel(dict.sce_dict);
classlist = cell(num_objcls+num_scecls,1);
for i = 1:num_objcls
    classlist{i} = dict.obj_dict{i}{1};
end
for i = 1:num_scecls
    classlist{i+num_objcls} = dict.sce_dict{i}{1};
end