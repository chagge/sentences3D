function histogram_coreferen()
datadir = '/Users/kongchen/sentences3D/NYU';
gt_dir = fullfile(datadir, 'descriptions_gt');
history_file = fullfile(datadir, 'history.mat');
dict_file = fullfile(datadir, 'learned_dict.mat');
dest_file = fullfile(datadir, 'histogram_coref');

history = load(history_file);
labeled = history.labeled;
desclist = gen_desclist(labeled);
dict = load(dict_file);
classlist = dict.classlist;
% classlist = classlist(1:numel(dict.obj_dict));
num_objcls = numel(dict.obj_dict);
hist_coref = zeros(num_objcls, 1);
invalid = {'it','its','they','their','them','one','room'};

for i = 1: numel(desclist)
    gt_file = fullfile(gt_dir, ['gt',desclist{i}, '.mat']);
    gt = load(gt_file);
    nouns = gt.noun;
    num_noun = numel(nouns);
    for i_noun = 1: num_noun
        noun = nouns{i_noun};
        if ~isempty(noun.co)
            cls_id = find(strcmp(classlist, noun.cls));
            if isempty(cls_id)
                error('A coreference does not belong to any obj class!');
            end
            if cls_id > num_objcls
                continue;
            end
            if isempty(find(strcmp(invalid,noun.word),1))
                hist_coref(cls_id) = hist_coref(cls_id) + 1;
            end
        end
    end
end
save(dest_file,'hist_coref');