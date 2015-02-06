function stat_word
datadir = '/Users/kongchen/sentences3D/NYU';
infodir = fullfile(datadir, 'descriptions_info');
classfile = fullfile(datadir, 'word_class.mat');
destfile = fullfile(datadir, sprintf('word_feature.mat'));
class = load(classfile);
class = class.class;
n_cls = numel(class);
for icls = 1:n_cls
    feature(icls).tag = class{icls};
    feature(icls).word = {};
end
scen_num = 800;
try
for i_sce = 1:scen_num
    infofile = fullfile(infodir, sprintf('in%04d.mat',i_sce));
    annot = load(infofile);
    desc_num = numel(annot.descriptions);
    for i_desc = 1:desc_num
        sent_num = numel(annot.descriptions(i_desc).tag);
        for i_sent = 1:sent_num
            word_num = size(annot.descriptions(i_desc).tag{i_sent},1);
            for i_word = 1:word_num
                id = find(strcmp(class,annot.descriptions(i_desc).tag{i_sent}{i_word,2}));
                if isempty(id)
                    continue;
                end
                id_word = find(strcmp(feature(id).word(:),annot.descriptions(i_desc).tag{i_sent}{i_word,1}));
                if isempty(id_word)
                    temp = cell(1,2);
                    temp{1} = annot.descriptions(i_desc).tag{i_sent}{i_word,1};
                    temp{2} = 1;
                    feature(id).word = [feature(id).word; temp];
                else
                    feature(id).word{id_word,2} = feature(id).word{id_word,2}+1;
                end
            end            
        end
    end
end
catch
    a = 1;
end
save(destfile,'feature');