function initial_dict(option)
data_globals;

to_use_wordnet = nargin >= 1 && strcmpi(option, 'wordnet');

if to_use_wordnet
    syn_path = '/Users/kongchen/sentences3D/code/parser';
    javaaddpath(syn_path);
    destfile = fullfile(DATADIR, 'origin_dict_w.mat');
else
    destfile = fullfile(DATADIR, 'origin_dict.mat');
end

obj_classes = load(CLASS_REDUCED);
sce_classes = load(SCENE_CLASSES);

nocls = numel(obj_classes.classes);
obj_dict = cell(nocls, 1);
for iocls = 1:nocls
    if to_use_wordnet
    % use Wordnet to initiate dict
        word = obj_classes.classes{iocls};
        syn = KC_Syns(word);
        synonyms = char(syn.ShowSynSet);
        syn_set = regexp(synonyms, ' ','split');
        obj_dict{iocls} = syn_set;
    else
    % only use classes' name
    obj_dict{iocls} = {obj_classes.classes{iocls}}; %#ok<CCAT1>
    end
end

nscls = numel(sce_classes.classes);
sce_dict = cell(nscls,1);
for iscls = 1:nscls
    if to_use_wordnet
        word = sce_classes.classes{iscls};
        syn = KC_Syns(word);
        synonyms = char(syn.ShowSynSet);
        syn_set = regexp(synonyms, ' ','split');
        sce_dict{iscls} = syn_set;
    else
        sce_dict{iscls} = {sce_classes.classes{iscls}}; %#ok<CCAT1>
    end
end

prep_dict{1} = {'on'};
prep_dict{2} = {'on_top_of', 'top'};
prep_dict{3} = {'in_front_of', 'front'};
prep_dict{4} = {'near', 'next_to', 'around', 'next'};
prep_dict{5} = {'right'};
prep_dict{6} = {'left'}; 
prep_dict = prep_dict';%#ok<NASGU>

save(destfile, 'obj_dict', 'sce_dict', 'prep_dict');