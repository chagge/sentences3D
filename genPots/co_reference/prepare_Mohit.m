function prepare_Mohit()
data_globals;
split = load(SPLIT_FILE);
set = [split.train; split.test];

dir = fullfile(DATADIR, 'Mohit_gt_k');
if ~exist(dir, 'dir')
    mkdir(dir);
else
    unix(sprintf('rm -r %s', dir));
    mkdir(dir);
end

for i_set = 1:numel(set)
    i_sce = set(i_set);
    if mod(i_set, 40) == 0 
        fprintf('doing %d\n', i_set); 
    end
    file = fullfile(GTS_DIR, sprintf('gt%04d.mat', i_sce));
    if ~exist(file, 'file')
        continue;
    end
    gt = load(file);
    coref = {};
    
    nouns = gt.noun;
    num_nouns = numel(nouns);
    
    for i_nouns = 1:num_nouns
        noun = nouns{i_nouns};
        if ~noun.isnoun
            continue;
        end
        if ~isempty(noun.co)
            id = noun.id;
            co_id = noun.co(:,1:2);
            if size(co_id, 1) == 1
                id_c = check_coref(coref, co_id);
                if id_c == 0
                    if co_id(1)*100 + co_id(2) - id(1)*100 - id(2) > 0
                        coref = [coref, [id; co_id]];
                    else
                        coref = [coref, [co_id; id]]; %#ok<*AGROW>
                    end
                else
                    coref{id_c} = [coref{id_c}; id]; 
                end
            else
                coref = [coref, [id; co_id]];
            end
        end
    end
  
    file = fullfile(dir, sprintf('%04d.txt.gt', i_sce));
    fid = fopen(file, 'w+');
    text_write(coref, gt, fid);
    fclose(fid);
end

function id_c = check_coref(corefs, id)
num_coref = numel(corefs);
for i_coref = 1:num_coref
    coref = corefs{i_coref};
    if ismember(id, coref, 'rows');
        id_c = i_coref;
        return;
    end
end
id_c = 0;

function text_write(corefs, gt, fid)

num_coref = numel(corefs);
for i_coref = 1:num_coref
    coref = corefs{i_coref};
    num_words = size(coref, 1);
    word_key = coref(1,:);
    text_key = gt.noun{gt.findnoun(word_key(1), word_key(2))}.word;
    fprintf(fid, 'Coreference set:\n');
    for i_words = 2:num_words
       word_co = coref(i_words, :);
       text_co = gt.noun{gt.findnoun(word_co(1), word_co(2))}.word;
        fprintf(fid, '	(%d,%d,[%d,%d)) -> ',word_co(1), word_co(2), word_co(2), word_co(2)+1);
        fprintf(fid, '(%d,%d,[%d,%d)), ', word_key(1), word_key(2), word_key(2), word_key(2)+1);
        fprintf(fid, 'that is: "%s" -> "%s"\n',text_co, text_key);
    end
end

