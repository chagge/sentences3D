function histogram_rgb
datadir = '/Users/kongchen/sentences3D/NYU';
final_dir = fullfile(datadir, 'descriptions_final');
eval_dir = fullfile(datadir, 'descriptions_eval');
split_file = fullfile(datadir, 'split.mat');
histogram_adj_class_file = fullfile(datadir, 'histogram_adj_class.mat');
objclass_file = fullfile(datadir, 'classes_reduced.mat');
% dataset_file = fullfile(datadir, 'nyu_depth_v2_labeled.mat');

% dataset = load(dataset_file);

split = load(split_file);
train_all = [split.train; split.val];
labeled = [1:800,1341:1449];
train = intersect(train_all, labeled);

hist_adj_cls = load(histogram_adj_class_file);
hist_color = hist_adj_cls.his_color;
objcls = load(objclass_file);
num_objcls = numel(objcls.classes);

hist_rgb = cell(size(hist_color,1), num_objcls);

for i_sce = train
    final_file = fullfile(final_dir, sprintf('04%d.mat', i_sce));   
    final = load(final_file);
    annotation = final.annotation;
    num_desc = numel(annotation.decriptions);
    seg = annotation.seg;
    
    for i_desc = 1:num_desc
        descriptions_f = annotation.descriptions(i_desc);
        words_f = descriptions_f.words;
        obj_id_f = descriptions_f.obj_id;
        
        [sentence, bias] = getbias(words_f);
        
        eval_file = fullfile(eval_dir, sprintf('ev%04d_%d.mat', i_sce, i_desc));
        eval = load(eval_file);
        
        nouns_e = eval.noun_ev;
        num_noun = numel(nouns_e);
        
        for i_noun = 1:num_noun
            noun_e = nouns_e(i_noun);
            noun_adj = noun_e.adj;
            num_noun_adj = numel(noun_adj);
            for i_noun_adj = 1:num_noun_adj
                adj = noun_adj{i_noun_adj};
                clcls = find(strcmp(hist_adj, adj));
                if isempty(clcls)
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
                    hist_rgb = update_rgb(hist_rgb, clcls, noun_clsid, seg{o}, dataset.images(:,:,:,i_sce));
                end
            end
        end
    end
end


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

function hist_rgb = update_rgb(hist_rgb, clcls, clsid, seg, image)
mask = roipoly(zeros(480,640), seg(:, 1), seg(:, 2));
[p_x, p_y] = find(mask ~= 0);
for i = 1:numel(p_x)
    rgb(1) = image(p_x, p_y,1);
    rgb(2) = image(p_x, p_y,2);
    rgb(3) = image(p_x, p_y,3);
    hist_rgb{clcls, clsid} = [hist_rgb{clcls, clsid}, rgb];
end
    