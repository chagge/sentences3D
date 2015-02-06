function correct_indexing()
data_globals;
fnlcls = load(CLASS_FINAL);
for i_sce=1:1449
    file = fullfile([GTS_DIR, '_wrongindex'], sprintf('gt%04d.mat', i_sce));
%     file = fullfile([GTS_DIR, ''], sprintf('gt%04d.mat', i_sce));
    if ~exist(file, 'file')
        fprintf('scene %d miss GT\n', i_sce);
        continue;
    end 
    gt = load(file);
    if isfield(gt, 'version')
        if gt.version == 2.00
            continue;
        end
    end
    nouns = gt.noun;
    num_nouns = numel(nouns);
    
    [gt.num_noun, gt.num_noun_with_it] = num_cluster(nouns, fnlcls.classes);
    word = 1;
    sent = 1;
    bias = 0;
    new_index = [];
    findnoun = [];
    for i_noun = 1:num_nouns
        noun = nouns{i_noun};
        id = [sent, word];
        word = word + 1;
        if strcmp(noun.word, '.')
            word = 1;
            sent = sent + 1;
            bias = 0;
        end
        new_index{id(1)}{id(2)-bias} = id; %#ok<AGROW>
        findnoun(id(1), id(2)) = i_noun; %#ok<AGROW>
        gt.noun{i_noun}.id = id;
        if ~isempty(strfind(noun.word, ''''))
            bias = bias + 1;
            word = word + 1;
        end
    end
    
    gt.new_index = new_index;
    gt.findnoun = findnoun;
    
    preps = gt.prep;
    num_preps = size(preps, 1);
    for i_preps = 1:num_preps
        id1 = preps{i_preps, 1};
        id2 = preps{i_preps, 3};
        id3 = preps{i_preps, 4};
        if isempty(id1)
            continue;
        end
        id1(1:2) = new_index{id1(1)}{id1(2)};
        gt.prep{i_preps, 1} = id1;
        if ~isempty(id2)
            id2(1:2) = new_index{id2(1)}{id2(2)};
            gt.prep{i_preps, 3} = id2;
        end
        if ~isempty(id3)
            id3(1:2) = new_index{id3(1)}{id3(2)};
            gt.prep{i_preps, 4} = id3;
        end
    end
    gt.version = 2.00;
    nouns = gt.noun;
    for i_nouns = 1:num_nouns
        noun = nouns{i_nouns};
        if isempty(noun.co)
            continue;
        end
        cos = noun.co(:, 1:2);
        num_co = size(cos, 1);
        for i_cos = 1:num_co
            co = cos(i_cos, :);
            co = new_index{co(1)}{co(2)};
            cos(i_cos, :) = co;
        end
        noun.co = cos;
        nouns{i_nouns} = noun;
    end
    for i_nouns = 1:num_nouns
        noun = nouns{i_nouns};
        if isempty(noun.co)
            continue;
        end
        cos = noun.co;
        num_co = size(cos, 1);
        for i_cos = 1:num_co
            co = cos(i_cos, :);
            nid = findnoun(co(1), co(2));
            nouns{nid}.co = [nouns{nid}.co; noun.id];
        end
    end
    for i_nouns = 1:num_nouns
        nouns{i_nouns}.co = unique(nouns{i_nouns}.co, 'rows');
    end
    gt.noun = nouns;
    
    file = fullfile([GTS_DIR, ''], sprintf('gt%04d.mat', i_sce));
    save(file, '-struct', 'gt');
end

function [num_noun, num_noun_with_it] = num_cluster(nouns, classes)
data_globals;
num_noun = 0;
num_noun_with_it = 0;
c = 1;
num_nouns = numel(nouns);
for i_nouns = 1:num_nouns
    noun = nouns{i_nouns};
    if noun.isnoun
        if ismember(noun.cls, classes)
            if c
                if ~ismember(noun.word, PRO_LIST)
                    num_noun = num_noun + 1;
                end
                num_noun_with_it = num_noun_with_it + 1;
                c = 0;
            end
        else
            c = 1;
        end
    else
        c = 1;
    end
end