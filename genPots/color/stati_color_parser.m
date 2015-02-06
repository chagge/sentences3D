function colorlist = stati_color_parser(option)

nyu_globals;

datadir = DATASET_ROOT;
final_dir = fullfile(datadir, 'descriptions_final');
eval_dir = fullfile(datadir, 'descriptions_eval');
split_file = fullfile(datadir, 'split.mat');
histogram_adj_class_file = fullfile(LOCAL_DIR, 'descriptors', 'histogram_adj_class.mat');


if nargin >0 && strcmp(option, 'reduce')
    reduce = [1:4,1,5,6,1,6,0,6,1,0,0,4,0,0,0,1,0,0,0,0];
    origin = [1:4,6,7];
    colorlist_file = fullfile(LOCAL_DIR, 'descriptors', 'colorlist_reduced.mat');
else
    reduce = (1:23);
    origin = (1:23);
    colorlist_file = fullfile(LOCAL_DIR, 'descriptors', 'colorlist.mat');
end
% objclass_file = fullfile(datadir, 'classes_reduced.mat');
% dataset_file = fullfile(datadir, 'nyu_depth_v2_labeled.mat');

% dataset = load(dataset_file);

labeled = [1:800, 1341:1449];



split = load(split_file);
train = split.train;
val = split.val;
test = split.test;
dataset = [train; val; test];
dataset = intersect(labeled, dataset);

hist_adj_cls = load(histogram_adj_class_file);
hist_color = hist_adj_cls.his_color;
% objcls = load(objclass_file);
% num_objcls = numel(objcls.classes);

for i_cls = 1:size(hist_color,1)
    if ~ismember(i_cls, origin)
        continue;
    end
    colorlist(reduce(i_cls)).name = hist_color{i_cls,1};
    colorlist(reduce(i_cls)).place = [];
    colorlist(reduce(i_cls)).object = {};
    colorlist(reduce(i_cls)).seg = {};
    colorlist(reduce(i_cls)).num_appearance = 0;
end

for i_sce = 1:numel(dataset)
    final_file = fullfile(final_dir, sprintf('%04d.mat', dataset(i_sce)));   
    final = load(final_file);
    annotation = final.annotation;
    num_desc = numel(annotation.descriptions);
    seg = annotation.seg;    
    for i_desc = 1:num_desc
        descriptions_f = annotation.descriptions(i_desc);
        words_f = descriptions_f.words;
        obj_id_f = descriptions_f.obj_id;
        
        [sentence, bias] = getbias(words_f);
        
        eval_file = fullfile(eval_dir, sprintf('ev%04d_%d.mat', dataset(i_sce), i_desc));
        eval = load(eval_file);
        
        nouns_e = eval.noun_ev;
        num_noun = numel(nouns_e);
        
        for i_noun = 1:num_noun
            noun_e = nouns_e(i_noun);
            noun_adj = noun_e.adj;
            num_noun_adj = numel(noun_adj);
            for i_noun_adj = 1:num_noun_adj
                adj = noun_adj{i_noun_adj};
                clcls = find(strcmp(hist_color, adj));
                if isempty(clcls)
                    continue;
                end
                clcls = reduce(clcls);
                if ~clcls
                    continue;
                end
                noun_clsid = str2num(noun_e.class_id(2:end));
                noun_id = noun_e.id;
                noun_f_id = sum(sentence.num_word(1:noun_id(1)-1)) + noun_id(2) + bias;
                o_id_s = obj_id_f{noun_f_id};
                if ~ischar(o_id_s)
                    continue;
                end
                o_id = str2num(o_id_s);
                num_o_id = numel(o_id);
                for i_o_id = 1:num_o_id;
                    o = o_id(i_o_id);
%                     colorlist(clcls).place = [colorlist(clcls).place; [dataset(i_sce), i_desc]];
                    colorlist(clcls).place = [colorlist(clcls).place; dataset(i_sce)];
                    colorlist(clcls).object = [colorlist(clcls).object; noun_clsid]; %#ok<*AGROW>
                    try
                    colorlist(clcls).seg = [colorlist(clcls).seg; seg(o)];
                    catch %#ok<CTCH>
                        fprintf('there is no seg for image %d, description %d, words %d\n', dataset(i_sce), i_desc, o);
                        fprintf('and use seg for image %d, description %d, words %d to replace\n', dataset(i_sce), i_desc, o-1);
                        colorlist(clcls).seg = [colorlist(clcls).seg; seg(o-1)];
                    end
                    colorlist(clcls).num_appearance = colorlist(clcls).num_appearance + 1;
                end
            end
        end
    end
end
save(colorlist_file, 'colorlist');


function [sentence, bias] = getbias(words_f)
num_words_f = numel(words_f);       
id_stop = [];
bias = 0;
i_sent = 1;
i_word = 1;
for i_words_f = 1:num_words_f            
    if strcmp(words_f{i_words_f},'.');
        i_sent = i_sent + 1;
        i_word = 1;
        id_stop = [id_stop, i_words_f];
        bias(i_sent, i_word) = 0;
        continue;
    end
    if ~isempty(strfind(words_f{i_words_f}, ''''))
        bias(i_sent, i_word+1) = bias(i_sent, i_word) - 1;
    else
        bias(i_sent, i_word+1) = bias(i_sent, i_word);
    end
end
sentence.num_word(1) = id_stop(1);
for i_sent = 2:numel(id_stop)
    sentence.num_word(i_sent) = id_stop(i_sent) - id_stop(i_sent-1);
end


