function parse_mohit()
data_globals;

for i_file = 1:1449
    if mod(i_file, 100) == 0
        fprintf('Processed %d / 1449 \n', i_file)
    end
    core = [];
    sw2s = [];
    s2sw = [];
    for i_dis = -1:6
        dir = fullfile(COREF_DIR, ['descriptions_final_corefOutput_maxDist', num2str(i_dis)]);
        file = fullfile(dir, sprintf('%04d.txt.out', i_file));
        text = textread(file, '%s', 'delimiter', '\n', 'bufsize', 4095000); %#ok<REMFF1>
        ids = find(strcmp(text, 'Coreference set:'));
        ids = [ids; numel(text)+1];
        for i_id = 1:numel(ids)-1
            id = ids(i_id);
            coref = [];
            for i_co = 1:ids(i_id+1) - id -1
                coref_set = text{id+i_co};
                coref_word = textscan(coref_set, '(%d,%d,[%d,%d)) -> (%d,%d,');
                cor = vertcat(coref_word{:})';
                cor = double(cor([1:2; 5:6]));
                coref = [coref; cor];
            end
            coref = unique(coref, 'rows');
            
            flag = 0;
            coref_s = zeros(size(coref, 1), 1);
            for i_co = 1:size(coref, 1);
                corr = coref(i_co, :);
                [ia, ib] = ismember(corr, s2sw, 'rows');
                if ~ia
                    s2sw = [s2sw; corr]; %#ok<AGROW>
                    coref_s(i_co) = size(s2sw, 1);
                    sw2s(corr(1), corr(2)) = coref_s(i_co); %#ok<AGROW>
                    flag = 1;
                else
                    coref_s(i_co) = ib;
                end
            end
            for x = 1:numel(coref_s);
                for y = 1:numel(coref_s)
                    if flag
                        core(coref_s(x), coref_s(y)) = 1;
                    else
                        core(coref_s(x), coref_s(y)) = core(coref_s(x), coref_s(y)) + 1;
                    end
                end
            end
        end
    end
    core = core - diag(diag(core));
    core = core/8;
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_file));
    if ~exist(info_file, 'file')
        continue;
    end
    info = load(info_file);
    if isempty(info.descriptions)
        continue;
    end
    info.descriptions.coref.prob = core;
    info.descriptions.coref.s2sw = s2sw;
    info.descriptions.coref.sw2s = sw2s;
    info = store_coref_info(info, 'noun_final');
    info = store_coref_info(info, 'noun_reduced');
    info = store_coref_info(info, 'noun_all'); %#ok<NASGU>
    save(info_file, '-struct', 'info');
end

function info = store_coref_info(info, setname)
nouns = info.descriptions.(setname);
id_noun = [];
core = info.descriptions.coref.prob;
sw2s = info.descriptions.coref.sw2s;
s2sw = info.descriptions.coref.s2sw;
for i_noun = 1:numel(nouns)
    noun = nouns(i_noun);
    info.descriptions.(setname)(i_noun).coref = [];
    info.descriptions.(setname)(i_noun).coref_prob = [];
    id_noun = [id_noun; noun.id]; %#ok<AGROW>
end
if isempty(core)
    return;
end
for i_noun = 1:numel(nouns)
    noun = nouns(i_noun);
    [ia, ib] = ismember(noun.id, s2sw, 'rows');
    if ia
        ic = find(core(ib, :) > 0);
        info.descriptions.(setname)(i_noun).coref = ...
            s2sw(ic,:);
        info.descriptions.(setname)(i_noun).coref_prob = ...
            core(ib, ic)';
    end
end