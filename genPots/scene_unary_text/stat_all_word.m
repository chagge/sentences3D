function stat_all_word
datadir = '/Users/kongchen/sentences3D/NYU';
infodir = fullfile(datadir, 'descriptions_info');
destfile = fullfile(datadir, sprintf('word_class.mat'));
class = {};
scen_num = 800;
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
                    class = [class, annot.descriptions(i_desc).tag{i_sent}{i_word,2}];
%                     if strcmp(annot.descriptions(i_desc).tag{i_sent}{i_word,2},'$');
%                         a = 1;
%                     end
                end
            end            
        end
    end
end
save(destfile,'class');