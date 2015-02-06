function extract_info()
%% Extract info(isent)rmation from sentences. Preparing dataset.
%
%   info(isent) = EXTRACT_info(isent)()
%

%% set path
data_globals;
path = fullfile(DATADIR, 'parser');
parser_path = fullfile(path,'stanford-parser.jar');
parser_models_path = fullfile(path,'stanford-parser-3.2.0-models.jar');
java_api_path = fullfile(path,'edu.mit.jwi_2.2.6_jdk.jar');
codePath = fullfile(CODESDIR, 'genPots', 'parser');

javaaddpath(parser_path);
javaaddpath(parser_models_path);
javaaddpath(java_api_path);
javaaddpath(path);
javaaddpath(codePath);

colordir = fullfile(DATADIR, 'descriptions');
dict_file = fullfile(path, 'learned_dict_w_s.mat');
evaldir = fullfile(DATADIR, 'descriptions_eval_k');
if ~exist(INFO_DIR, 'dir')
    mkdir(INFO_DIR);
end
if ~exist(evaldir, 'dir')
    mkdir(evaldir);
end

dict = load(dict_file);

class_final = load(CLASS_FINAL);
reduced_to_final = class_final.reduced_to_final;
reduced_to_final = [reduced_to_final; 22];

%% extract sentences for stanford parser
disp('Preparing dataset...');
labeled = get_labeled('FINAL_DIR');
% labeled = 181;
s_num = numel(labeled);

sentences_all = [];
num_scecls = numel(dict.sce_dict);

disp('Extracting all sentences...');

for i_s = 1:numel(labeled);
    is = labeled(i_s);
    file = fullfile(FINAL_DIR,sprintf('%04d.mat',is));
    annotation = load(file);
    annotation = annotation.annotation;
    
    if isfield(annotation, 'imname')
        s(is).imname = annotation.imname;
    else
        s(is).imname = sprintf('%04d', is);
    end
    s(is).imsize = annotation.imsize;
    s(is).class = annotation.class;
    s(is).bboxes = annotation.bboxes;
%     s(is).truncated = annotation.truncated;
%     s(is).occluded = annotation.occluded;
    s(is).seg = annotation.seg;
%     s(is).box3D = annotation.box3D;
%     s(is).boxView = annotation.boxView;
%     s(is).angle = annotation.angle;
    s(is).descriptions = annotation.descriptions(1);
    
    file = fullfile(colordir,sprintf('%04d.mat',is));
    if exist(file, 'file')       
        color = load(file);
        s(is).color = color.annotation.color;
    else
        s(is).color = {};
    end
    
%     ndes = numel(annotation.descriptions);
    ndes = 1;
    
    iscene = find(labeled == is);
    if mod(iscene,200) == 0;
        fprintf('Processed %2.2f%%\n',iscene/s_num * 100);
    end
    
    for ides = 1 : ndes;
        dsc = annotation.descriptions(ides);
        id_stop = regexp(dsc.text,'\.');
        idx = 1;
        for i = 1:numel(id_stop);
            if i == 1
                tsen = dsc.text(1:id_stop(i)-1);
            else
                tsen = dsc.text(id_stop(i-1)+2:id_stop(i)-1);
            end
            if numel(tsen) <5
                continue;
            end
            tsen = lower(tsen);
            s(is).annotation(ides).info(idx).sentence = tsen;
            
%             a = strfind(tsen,'/');
%             if ~isempty(a)
%                 b = 1;
%             end
            
            sentences_all = [sentences_all, '# ', tsen]; %#ok<*AGROW>
            idx = idx + 1;
        end
        if isempty(id_stop)
            tsen = lower(dsc.text);
            s(is).annotation(ides).info(idx).sentence = tsen;
            sentences_all = [sentences_all, '# ', tsen];
%             idx = idx + 1;
        else
            if numel(dsc.text) - id_stop(i) >5;
                tsen = dsc.text(id_stop(i)+2:end);
                tsen = lower(tsen);
                s(is).annotation(ides).info(idx).sentence = tsen;
                sentences_all = [sentences_all, '# ', tsen];
%                 idx = idx + 1;
            end
        end
    end
end


fprintf('Parsing sentences...\n');

parser = KC_Parser(sentences_all);

parse_tree_all = char(parser.show_trees);
dependency_all = char(parser.show_dependencies);
tag_all = char(parser.show_tags);

parse_tree_split = split_all(parse_tree_all);
dependency_split = split_all(dependency_all);
tag_split = split_all(tag_all);
isent_all = 0;

disp('Extracting Info...');
for i_s = 1:numel(labeled)    
    is = labeled(i_s);
    imname = s(is).imname; %#ok<NASGU>
    imsize = s(is).imsize; %#ok<NASGU>    
    class = s(is).class; %#ok<NASGU>
    bboxes = s(is).bboxes; %#ok<NASGU>
%     truncated = s(is).truncated; %#ok<NASGU>
%     occluded = s(is).occluded; %#ok<NASGU>
    seg = s(is).seg; %#ok<NASGU>
%     box3D = s(is).box3D; %#ok<NASGU>
%     boxView = s(is).boxView; %#ok<NASGU>
%     angle = s(is).angle; %#ok<NASGU>
    descriptions = s(is).descriptions;
    color = s(is).color; %#ok<NASGU>
    
    iscene = find(labeled == is);
    if mod(iscene,100) == 0;
        fprintf('Processed %2.2f%%\n',iscene/s_num * 100);
    end
    
%     for idep = 1 : numel(descriptions)
    for idep = 1 : 1
        
        class_list = {};
        info = s(is).annotation(idep).info;
        descriptions(idep).verb = {};
        descriptions(idep).prep = {};
        descriptions(idep).scene = zeros(num_scecls,1);
        noun_ev = [];
        num_sss = 0;
        
        
        %% word
        words = descriptions(idep).words;
        obj_id = descriptions(idep).obj_id;
        words_n = {};
        obj_id_n = {};
        for i_word = 1:numel(words)
            word = words{i_word};
            o_id = obj_id{i_word};
            if strcmp(word, '.')
                continue;
            end
            id = strfind(word, '''');
            if ~isempty(id)
                words_n = [words_n, word(1:id-1)];
                obj_id_n{numel(obj_id_n)+1} = o_id;
                words_n = [words_n, word(id:end)];
                obj_id_n{numel(obj_id_n)+1} = o_id;
            else
                words_n = [words_n, word];
                obj_id_n{numel(obj_id_n)+1} = o_id;
            end
        end
        if numel(words_n) ~= numel(obj_id_n)
            error('sizes of words and obj_id are not consist!');
        end
        descriptions(idep).words = words_n;
        descriptions(idep).obj_id = obj_id_n;
        %%
        for isent = 1:numel(info)
            
            isent_all = isent_all + 1;

            info(isent).parse_tree = parse_tree_split{isent_all};

            dependency = dependency_split{isent_all};
            tag = tag_split{isent_all};

            info(isent).dependency = ...
                regexp(dependency, ' ','split');

            info(isent).tag = regexp(tag, ' ', 'split');
            
            descriptions(idep).dependency{isent} = info(isent).dependency;
            
            temptag = info(isent).tag;
            temptag = regexp(temptag,'/','split');
            descriptions(idep).tag{isent} = vertcat(temptag{:});

            
            
    %% noun
            noun = [];
            plural = [];
            id_NN = regexp(info(isent).tag,'NN');
            id_PRO = regexp(info(isent).tag, 'PRP');
            for i = 1:size(id_NN,2);
                if ~isempty(id_NN{i}) || ~isempty(id_PRO{i})
                    ttag = info(isent).tag{i};
                    id_comma = regexp(ttag,'/');
                    tnoun.word = ttag(1:id_comma-1);
                    tnoun.id = num2str(i);
                    tplural = 1;
                    if ttag(end)=='S';
                        tplural = 2;
                    end
                    tnoun.cardinality = 0;
                    tnoun.adj = {};
                    noun = [noun, tnoun];
                    plural = [plural, tplural];
                end
            end
            %extract number in sentence
            id_num = regexp(dependency,'num(');
            for i = 1:size(id_num,2);
                id_comma = regexp(dependency(id_num(i):end),',');
                id_hyphen = regexp(dependency(id_num(i):end),'-');
                tempnounid = dependency(id_num(i)+id_hyphen(1):id_num(i)+id_comma(1)-2);
                tempcard = dependency(id_num(i)+id_comma(1):id_num(i)+id_hyphen(2)-2);
                tempcardinality = KC_str2num(tempcard, ROOT);
                if isempty(tempcardinality)
                    continue;
                end
                for j = 1:size(noun,2);
                    if strcmp(noun(j).id, tempnounid);
                        noun(j).cardinality = noun(j).cardinality + tempcardinality;
                    end
                end
            end

            id_nn = regexp(dependency,'nn(');
            for i = 1:size(id_nn,2);
                id_comma = regexp(dependency(id_nn(i):end),',');
                id_hyphen = regexp(dependency(id_nn(i):end),'-');
                id_bracket = regexp(dependency(id_nn(i):end),')');
                tempnoun1id = dependency(id_nn(i)+id_hyphen(1):id_nn(i)+id_comma(1)-2);
                tempnoun2 = dependency(id_nn(i)+id_comma(1):id_nn(i)+id_hyphen(2)-2);
                tempnoun2id = dependency(id_nn(i) + id_hyphen(2):id_nn(i)+id_bracket-2);
                
                
                %tempcardinality = KC_str2num(tempnoun2);
                
%                 try
                    tempcardinality = KC_str2num(tempnoun2, ROOT);
%                 catch
%                     fprintf('%d  %d  %d',is,idep,isent);
%                     pause;
%                 end
                for j = 1:size(noun,2);
                    if ~isempty(tempcardinality)
                        if strcmp(noun(j).id, tempnoun1id);                   
                            noun(j).cardinality = noun(j).cardinality + tempcardinality;
                            continue;
                        end
                    else
                        if strcmp(noun(j).id, tempnoun2id); 
                            %modify cardinality since certain noun works as adj.                    
                            noun(j).cardinality = noun(j).cardinality -1;
                            continue;
                        end
                    end
                end
            end
            % prepare for removing nouns whose cardinality is zero.
            r = 0;
            %modify cardinality since certain noun does have a number
            for i = 1:numel(noun);
                if noun(i - r).cardinality <= 0;
                    noun(i - r).cardinality = noun(i - r).cardinality + plural(i);
                    if noun(i - r).cardinality <= 0;
                        noun = noun([(1:i - r-1),(i - r+1:numel(noun))]);
                        r = r + 1;
                    end
                end
            end

            % add adj to noun        
            id_JJ = regexp(info(isent).tag,'JJ');
            for i = 1:numel(id_JJ)
                if id_JJ{i};
                    adj = info(isent).tag{i};
                    adj = adj(1:id_JJ{i}-2);
                    adjid = num2str(i);
                    for j = 1:numel(noun)
                        temp = ['nusbj(',adj,'-',adjid,',',noun(j).word,'-',noun(j).id];
                        temp2 = ['amod(',noun(j).word,'-',noun(j).id,',',adj,'-',adjid];
                        if ~isempty([regexp(dependency, temp), regexp(dependency, temp2)])
                            noun(j).adj = [noun(j).adj, adj];
                            continue;
                        end
                    end
                end
            end
            info(isent).noun = noun;
    %         %get objects' cardinality
    %         %put objects,that doesn't belong to any classes, into class 'other'
    %         descriptions.cardinality.obj = zeros(1,size(objects,2));
    % 
    %         for i = 1:size(noun,2);
    %             j = get_id(noun(i).word,objects,0);
    %             descriptions.cardinality.obj(j) = descriptions.cardinality.obj(j) + noun(i).cardinality;
    %         end
    % 
    % 
    %         %get scene types'cardinality
    %         descriptions.cardinality.sce = zeros(1,size(objects,2));
    % 
    %         for j = 1:size(noun,2);
    %             i = get_id(noun(j).word,scenetypes,1);
    %             if i == -1;
    %                 continue;
    %             end
    %             descriptions.cardinality.sce(i) = descriptions.cardinality.sce(i) + noun(j).cardinality;
    %         end 
    %% prep
            id_prep = regexp(dependency,'prep_');
            id_nsubj = regexp(dependency,'nsubj(');
            prep2 = {};
            prepnoun2 = {};
            temppp = cell(1,3);
            for i = 1:size(id_prep,2);
                id_comma = regexp(dependency(id_prep(i):end),',');
                id_hyphen = regexp(dependency(id_prep(i):end),'-');
                id_bracket = regexp(dependency(id_prep(i):end),'(');
                id_bracket2 = regexp(dependency(id_prep(i):end),')');
                tempprep = dependency(id_prep(i)+5:id_prep(i)+id_bracket(1)-2);
                if strcmp(tempprep,'between');
                    continue;
                end
                tempnoun1 = dependency(id_prep(i)+id_bracket(1):id_prep(i)+id_hyphen(1)-2);
                tempid1 = dependency(id_prep(i)+id_hyphen(1):id_prep(i)+id_comma(1)-2);
                tempnoun2 = dependency(id_prep(i)+id_comma(1):id_prep(i)+id_hyphen(2)-2);
                tempid2 = dependency(id_prep(i)+id_hyphen(2):id_prep(i)+id_bracket2(1)-2);
                
                taggednoun1 = info(isent).tag{str2num(tempid1)};
                id_split = regexp(taggednoun1,'/');
                tagnoun1 = taggednoun1(id_split(1)+1:end);
                if strcmp(tagnoun1,'JJ')
                    tempprep = [tempnoun1,'_', tempprep];
                end
                temppp{3} = tempprep;
                for j = 1:size(id_nsubj,2);
                    id_comma = regexp(dependency(id_nsubj(j):end),',');
                    id_hyphen = regexp(dependency(id_nsubj(j):end),'-');
                    id_bracket = regexp(dependency(id_nsubj(j):end),')');
                    tempid3 = dependency(id_nsubj(j)+id_hyphen(1):id_nsubj(j)+id_comma(1)-2);
                    tempid4 = dependency(id_nsubj(j)+id_hyphen(2):id_nsubj(j)+id_bracket(1)-2);
                    if strcmp(tempid1,tempid3);
                        tempnoun1 = dependency(id_nsubj(j)+id_comma(1):id_nsubj(j)+id_hyphen(2)-2);
                        tempid1 = tempid4;
                    end
                end
                temppp{1} = tempnoun1; 
                temppp{2} = tempnoun2;
                prepnoun2 = [prepnoun2; temppp];
                temppp{1} = [isent, str2num(tempid1), 1];
                temppp{2} = [isent, str2num(tempid2), 1];
                exchg = temppp{2};
                temppp{2} = temppp{3};
                temppp{3} = exchg;
                prep2 = [prep2; temppp];
            end

            %for 'between'
            id_between = regexp(dependency,'prep_between');
            prepnoun3 = {};
            prep3 = {};
            id_nsubj = regexp(dependency,'nsubj');
            flag = 0;
            for i = 1:size(id_between,2);
                if flag;
                    flag = 0;
                    continue;
                end
                id_comma = regexp(dependency(id_between(i):end),',');
                id_hyphen = regexp(dependency(id_between(i):end),'-');
                id_bracket = regexp(dependency(id_between(i):end),'(');
                id_bracket2 = regexp(dependency(id_between(i):end),')');
                tempnoun1 = dependency(id_between(i)+id_bracket(1):id_between(i)+id_hyphen(1)-2);
                tempid1 = dependency(id_between(i)+id_hyphen(1):id_between(i)+id_comma(1)-2);
                tempnoun2 = dependency(id_between(i)+id_comma(1):id_between(i)+id_hyphen(2)-2);
                tempid2 = dependency(id_between(i)+id_hyphen(2):id_between(i)+id_bracket2(1)-2);
                if i+1 <= size(id_between,2);
                    id_comma = regexp(dependency(id_between(i+1):end),',');
                    id_hyphen = regexp(dependency(id_between(i+1):end),'-');
                    id_bracket2 = regexp(dependency(id_between(i+1):end),')');
                    tempid3 = dependency(id_between(i+1)+id_hyphen(1):id_between(i+1)+id_comma(1)-2);
                    tempnoun4 = dependency(id_between(i+1)+id_comma(1):id_between(i+1)+id_hyphen(2)-2);
                    tempid4 = dependency(id_between(i+1)+id_hyphen(2):id_between(i+1)+id_bracket2(1)-2);
                    if strcmp(tempid1,tempid3);
                        flag = 1;
                        for j = 1:size(id_nsubj,2);
                            id_comma = regexp(dependency(id_nsubj(j):end),',');
                            id_hyphen = regexp(dependency(id_nsubj(j):end),'-');
                            id_bracket = regexp(dependency(id_nsubj(j):end),')');
                            tempid5 = dependency(id_nsubj(j)+id_hyphen(1):id_nsubj(j)+id_comma(1)-2);
                            if strcmp(tempid1,tempid5);
                                tempnoun1 = dependency(id_nsubj(j)+id_comma(1):id_nsubj(j)+id_hyphen(2)-2);
                                tempid1 = dependency(id_nsubj(j)+id_hyphen(2):id_nsubj(j)+id_bracket(1)-2);
                            end
                        end
                        temp = {tempnoun1,'between',tempnoun2,tempnoun4};
                        prepnoun3 = [prepnoun3; temp];
                        temp = {[isent, str2num(tempid1), 1],'between',...
                            [isent, str2num(tempid2), 1],[isent, str2num(tempid4), 1]};
                        prep3 = [prep3; temp];
                    else
                        for j = 1:size(id_nsubj,2);
                            id_comma = regexp(dependency(id_nsubj(j):end),',');
                            id_hyphen = regexp(dependency(id_nsubj(j):end),'-');
                            id_bracket = regexp(dependency(id_nsubj(j):end),')');
                            tempid5 = dependency(id_nsubj(j)+id_hyphen(1):id_nsubj(j)+id_comma(1)-2);
                            if strcmp(tempid1,tempid5);
                                tempnoun1 = dependency(id_nsubj(j)+id_comma(1):id_nsubj(j)+id_hyphen(2)-2);
                                tempid1 = dependency(id_nsubj(j)+id_hyphen(2):id_nsubj(j)+id_bracket(1)-2);
                            end
                        end
                        temp = {tempnoun1,'between',tempnoun2,tempnoun2};
                        prepnoun3 = [prepnoun3; temp];
                        temp = {[isent, str2num(tempid1),1],'between',...
                            [isent, str2num(tempid2), 1], [isent, str2num(tempid2), 2]};
                        prep3 = [prep3; temp];
                    end
                else
                    for j = 1:size(id_nsubj,2);
                        id_comma = regexp(dependency(id_nsubj(j):end),',');
                        id_hyphen = regexp(dependency(id_nsubj(j):end),'-');
                        id_bracket = regexp(dependency(id_nsubj(j):end),')');
                        tempid5 = dependency(id_nsubj(j)+id_hyphen(1):id_nsubj(j)+id_comma(1)-2);
                        if strcmp(tempid1,tempid5);
                            tempnoun1 = dependency(id_nsubj(j)+id_comma(1):id_nsubj(j)+id_hyphen(2)-2);
                            tempid1 = dependency(id_nsubj(j)+id_hyphen(2):id_nsubj(j)+id_bracket(1)-2);
                        end
                    end
                    temp = {tempnoun1,'between',tempnoun2,tempnoun2};
                    prepnoun3 = [prepnoun3; temp];
                    tid1 = [isent, str2num(tempid1), 1];
                    tid2 = [isent, str2num(tempid2), 1];
                    temp = {tid1,'between',tid2,tid2};
                    prep3 = [prep3; temp];
                end
            end
            info(isent).prep2 = prep2;
            info(isent).prep3 = prep3;

    %% verb        
            verb = [];
            id_V = regexp(info(isent).tag,'/V');
            for i = 1:size(id_V,2);
                if id_V{i}
                    ttag = info(isent).tag{i};
                    id_split = regexp(ttag,'/');
                    tverb.word = ttag(1:id_split-1);
                    tverb.id = [isent, i];
                    verb = [verb, tverb];
                end
            end
            info(isent).verb = verb;

    %% to/on/in the ... of
            sent = info(isent).sentence;
            prep_phr = {'in', 'on', 'to', };
            prep_phr2 = {'of', 'side of'};
            for i_phr = 1 : numel(prep_phr)
                for i_phr2 = 1:numel(prep_phr2)
                    phra = [prep_phr{i_phr},'\sthe\s\S+\s', prep_phr2{i_phr2}];
                    id_phr = regexp(sent, phra);
                    for i_ph = 1:numel(id_phr)
                        id_of = regexp(sent(id_phr(i_ph):end),' of');
                        temp = cell(1, 3);
                        tempn = cell(1, 3);
                        n= id_phr(i_ph)+numel('on the ');
                        temp{3} = sent(n: id_phr(i_ph)+id_of-2);
                        tempn{3} = temp{3};
                        %get id
                        id_space = regexp(sent,' ');
                        for i = 1:numel(id_space)
                            if id_space(i) > n;
                                break;
                            end
                        end
                        %id_apo = regexp(sent, ''');
    %                     id3 = num2str(i);


                        %for temp{2}
                        %id_prep_of = regexp(dependency, ['prep_of(',temp{3},'-',id3,',']);
                        id_prep_of = regexp(dependency, ['prep_of(',temp{3},'-']);
                        if isempty(id_prep_of)
                            continue;
                        end
                        id_comma = regexp(dependency(id_prep_of(1):end),',');
                        id_bracket = regexp(dependency(id_prep_of(1):end),')');
                        id_hyphen = regexp(dependency(id_prep_of(1):end),'-');
                        tempn{2} = dependency(id_prep_of(1)+id_comma(1):id_prep_of(1)+id_hyphen(2)-2);
                        temp{2} = dependency(id_prep_of(1)+id_hyphen(2):id_prep_of(1)+id_bracket(1)-2);


                        %for temp{1}
                        %id_noun1 = regexp(dependency, ['prep_',prep_phr{i_phr}, '(\S+',tempn{3},'-',id3,')']);
                        id_noun1 = regexp(dependency, ['prep_',prep_phr{i_phr}, '(\S+',tempn{3},'-']);
                        if ~isempty(id_noun1)
                            id_comma = regexp(dependency(id_noun1(1):end),',');
    %                         id_bracket = regexp(dependency(id_noun1(1):end),')');
                            id_hyphen = regexp(dependency(id_noun1(1):end),'-');
                            tpn = dependency(id_noun1(1)+numel(['prep_',prep_phr{i_phr}, '(']):id_noun1(1)+id_hyphen(1)-2);
                            tp = dependency(id_noun1(1)+id_hyphen(1):id_noun1(1)+id_comma(1)-2);
                        else
                            id_noun1 = regexp(dependency,['nsubj(',tempn{3},'-']);
                            if ~isempty(id_noun1)
                                id_comma = regexp(dependency(id_noun1(1):end),',');
                                id_bracket = regexp(dependency(id_noun1(1):end),')');
                                id_hyphen = regexp(dependency(id_noun1(1):end),'-');
                                tpn = dependency(id_noun1(1)+id_comma(1):id_noun1(1)+id_hyphen(2)-2);
                                tp = dependency(id_noun1(1)+id_hyphen(2):id_noun1(1)+id_bracket(1)-2);
                            else
                                continue;
                            end
                        end



                        id_is = regexp(dependency, ['nsubj(',tpn,'-',tp]);
                        if ~isempty(id_is)
                            id_comma = regexp(dependency(id_is(1):end),',');
                            id_bracket = regexp(dependency(id_is(1):end),')');
                            id_hyphen = regexp(dependency(id_is(1):end),'-');
                            tpn = dependency(id_is(1)+id_comma(1):id_is(1)+id_hyphen(2)-2);
                            tp = dependency(id_is(1)+id_hyphen(2):id_is(1)+id_bracket(1)-2);
                        end
                        tempn{1} = tpn; %#ok<NASGU>
                        temp{1} = tp;
                        temp{1} = [isent, str2num(temp{1}), 1];
                        temp{2} = [isent, str2num(temp{2}), 1];
                        exchg = temp{2};
                        temp{2} = temp{3};
                        temp{3} = exchg;
                        info(isent).prep2 = [info(isent).prep2;temp];
                    end
                end            
            end
 

            %% scene type
            
            info(isent).scene = zeros(num_scecls, 1);
            for i_scecls = 1:num_scecls
                scecls_set = dict.sce_dict{i_scecls};
                num_sce_word = numel(scecls_set);
                for i_sceword = 1:num_sce_word
                    sceword_o = scecls_set{i_sceword};
                    sceword = strrep(sceword_o, '_', ' ');
                    appear = strfind(info(isent).sentence, sceword);
                    if ~isempty(appear)
                        info(isent).scene(i_scecls) = 1;
                    end
                    sceword = strrep(sceword_o, '_', '');
                    appear = strfind(info(isent).sentence, sceword);
                    if ~isempty(appear)
                        info(isent).scene(i_scecls) = 1;
                    end                  
                end
            end
            
            %% integrate info
            % prepare data for output
            for inoun = 1:numel(info(isent).noun)
                noun = info(isent).noun(inoun);
                [noun_class, noun_class_id] = get_class(noun.word, dict, ROOT);
                info(isent).noun(inoun).class = noun_class;
                info(isent).noun(inoun).class_id = noun_class_id;
                info(isent).noun(inoun).id = [isent, str2num(info(isent).noun(inoun).id)];
                info(isent).noun(inoun).id_word = num_sss + str2num(noun.id);
                iclass = find(strcmp(class_list, noun_class_id));
                if isempty(iclass)
                    iclass = numel(class_list)+1;
                    class_list = [class_list, noun_class_id];
                    descriptions(idep).class(iclass).name = noun_class;
                    descriptions(idep).class(iclass).id = noun_class_id;
                    descriptions(idep).class(iclass).cardinality = noun.cardinality;
                    for icard = 1:noun.cardinality;
                        descriptions(idep).class(iclass).instance(icard).id = [isent, str2num(noun.id), icard];
                        descriptions(idep).class(iclass).instance(icard).adj = noun.adj;
                        descriptions(idep).class(iclass).instance(icard).id_word = num_sss + str2num(noun.id);
                        descriptions(idep).class_instance_map{isent, str2num(noun.id), icard} = {iclass, icard};
                    end
                else
                    descriptions(idep).class(iclass).cardinality = ...
                        descriptions(idep).class(iclass).cardinality + noun.cardinality;
                    ninst = numel(descriptions(idep).class(iclass).instance);
                    for icard = 1:noun.cardinality;                       
                        descriptions(idep).class(iclass).instance(icard + ninst).id = ...
                            [isent, str2num(noun.id), icard];
                        descriptions(idep).class(iclass).instance(icard + ninst).adj = noun.adj;
                        descriptions(idep).class(iclass).instance(icard + ninst).id_word = num_sss + str2num(noun.id);
                        descriptions(idep).class_instance_map{isent, str2num(noun.id), icard} = {iclass, icard + ninst};
                    end
                end
            end
            
            for iverb = 1:numel(info(isent).verb)
                descriptions(idep).verb = [descriptions(idep).verb, info(isent).verb(iverb)];
            end
            if ~isempty(info(isent).prep2)                
                info(isent).prep2{1,4} = [];
                descriptions(idep).prep = [descriptions(idep).prep; info(isent).prep2];
            end 
            descriptions(idep).prep = [descriptions(idep).prep; info(isent).prep3];
       
            descriptions(idep).scene = descriptions(idep).scene + info(isent).scene;
            % prepare data for evluation
            noun_ev = [noun_ev, info(isent).noun];
            %% sentence
            for i_word = 1:numel(info(isent).tag);
                tag_se = info(isent).tag{i_word};
                id_se = regexp(tag_se, '/');
                word_se = tag_se(1:id_se(1)-1);
                descriptions(idep).sentences{isent}{i_word} = word_se;
                descriptions(idep).sent_word(isent, i_word) = num_sss + i_word;
            end
            num_sss = num_sss + numel(info(isent).tag);
%             %apply prep2 for every instance
%             for iprep2 = 1:numel(descriptions(idep).prep2)
%                 p_noun1_id = descriptions(idep).prep2{iprep2, 1};
%                 ipath1 = class_instance_map{p_noun1_id(1),p_noun1_id(2),p_noun1_id(3)};
%                 iclass1 = ipath1{1};
%                 iinst1 = ipath1{2};
%                 npinst1 = numel(descriptions(idep).class(iclass1).instance(iinst1));
%                 
%                 p_noun2_id = descriptions(idep).prep2{iprep2, 2};
%                 ipath2 = class_instance_map{p_noun2_id(1),p_noun2_id(2),p_noun2_id(3)};
%                 iclass2 = ipath2{1};
%                 iinst2 = ipath2{2};
%                 npinst2 = numel(descriptions(idep).class(iclass2).instance(iinst2));
%                 
%                 flag = 1;
%                 for ipinst1 = 2:npinst1
%                     flag = 0;
%                     for ipinst2 = 2:npinst2
%                         p_noun1_id(3) = ipinst1;
%                         p_noun2_id(3) = ipinst2;
%                         temp = {p_noun1_id, p_noun2_id, descriptions(idep).prep2{iprep2, 2}};
%                         descriptions(idep).prep2 = [descriptions(idep).prep2; temp];
%                     end
%                 end
%                 if flag
%                     for ipinst2 = 2:npinst2
%                         p_noun1_id(3) = ipinst1;
%                         p_noun2_id(3) = ipinst2;
%                         temp = {p_noun1_id, p_noun2_id, descriptions(idep).prep2{iprep2, 2}};
%                         descriptions(idep).prep2 = [descriptions(idep).prep2; temp];
%                     end
%                 end
%             end
            
%              %apply prep3 for every instance
%             for iprep3 = 1:numel(descriptions(idep).prep3)
%                 p_noun1_id = descriptions(idep).prep3{iprep3, 1};
%                 p_noun2_id = descriptions(idep).prep3{iprep3, 2};
%                 if p_noun2_id(1) == p_noun3_id
%                 
%                 ipath1 = class_instance_map{p_noun1_id(1),p_noun1_id(2),p_noun1_id(3)};
%                 iclass1 = ipath1{1};
%                 iinst1 = ipath1{2};
%                 npinst1 = numel(descriptions(idep).class(iclass1).instance(iinst1));
%                 
%                 
%                 ipath2 = class_instance_map{p_noun2_id(1),p_noun2_id(2),p_noun2_id(3)};
%                 iclass2 = ipath2{1};
%                 iinst2 = ipath2{2};
%                 npinst2 = numel(descriptions(idep).class(iclass2).instance(iinst2));
%                 
%                 p_noun3_id = descriptions(idep).prep3{iprep3, 3};
%                 ipath3 = class_instance_map{p_noun3_id(1),p_noun3_id(2),p_noun3_id(3)};
%                 iclass3 = ipath3{1};
%                 iinst3 = ipath3{2};
%                 npinst3 = numel(descriptions(idep).class(iclass3).instance(iinst3));
%                 
%                 for ipinst1 = 2:npinst1
%                     for ipinst2 = 2:npinst2
%                         p_noun1_id(3) = ipinst1;
%                         p_noun2_id(3) = ipinst2;
%                         temp = {p_noun1_id, p_noun2_id, descriptions(idep).prep2{iprep2, 2}};
%                         descriptions(idep).prep2 = [descriptions(idep).prep2; temp];
%                     end
%                 end
%             end          
            
        end
        descriptions(idep).scene = descriptions(idep).scene > 0;
        noun_reduced = [];
        noun_final = [];
        for i_noun_ev = 1:numel(noun_ev)
            noun_e = noun_ev(i_noun_ev);
            if ~strcmp(noun_e.class, 'background')
                noun_reduced = ...
                    [noun_reduced, noun_e];
            end
            class_id_final = reduced_to_final(str2num(noun_e.class_id(2:end)));
            if class_id_final
                noun_e.class_id_final = class_id_final;
                noun_final = ...
                    [noun_final, noun_e];
            end
        end
        nnoun = numel(noun_final);
        idlist = [];
        num_pronoun = 0;
        num_noun_final = 0;
        for i_n = 1:nnoun
            idlist = [idlist; noun_final(i_n).id];
            if noun_final(i_n).class_id_final == 22
                num_pronoun = num_pronoun + 1;
            else
                num_noun_final = num_noun_final + 1;
            end
        end
        descriptions(idep).noun_all = noun_ev;
        descriptions(idep).noun_reduced = noun_reduced;
        descriptions(idep).noun_final = noun_final;
        descriptions(idep).noun_final_list = idlist;
        descriptions(idep).num_pronoun = num_pronoun;
        descriptions(idep).num_noun_final = num_noun_final;
        scene = descriptions(idep).scene; %#ok<NASGU>
        prep = descriptions(idep).prep; %#ok<NASGU>
        evalfile = fullfile(evaldir, sprintf('ev%04d_%d.mat',is,idep));
        save(evalfile, 'noun_ev','scene','prep');
    end
    destfile = fullfile(INFO_DIR, sprintf('in%04d.mat',is));
    version = 'v-7.0'; %#ok<NASGU>
%     save(destfile, 'imname', 'imsize', 'class', 'bboxes', 'truncated',...
%         'occluded', 'seg', 'box3D', 'boxView', 'angle', 'descriptions', 'color', 'version');
    save(destfile, 'imname', 'imsize', 'class', 'bboxes', 'seg', ...
        'descriptions', 'color', 'version');
end



function [class_name, class_id] = get_class(word, dict, root)
%stem
%     path = '/share/data/sentences3D/Parser';
%     javaaddpath(path);
stem = stemmer(word, root);
word = char(stem.ShowStem);
data_globals;
%     for iscls = 1:numel(dict.sce_dict)
%         for iword = 1:numel(dict.sce_dict{iscls})
%             if strcmp(word, dict.sce_dict{iscls}{iword})
%                 class_name = dict.classlist{iscls+numel(dict.obj_dict)};
%                 class_id = ['s', num2str(iscls)];
%                 return;
%             end
%         end
%     end
dict.obj_dict = [dict.obj_dict; {PRO_LIST}];
dict.classlist{33} = 'pronoun';
for iocls = 1:numel(dict.obj_dict)
    for iword = 1:numel(dict.obj_dict{iocls})
        if strcmp(word, dict.obj_dict{iocls}{iword})
            class_name = dict.classlist{iocls};
            class_id = ['o', num2str(iocls)];
            return;
        end
    end
end
class_name = 'background';
class_id = 'o32';



function num = KC_str2num(str, root)
%% translate string to number
if ~ischar(str)
    num = [];
    return;
end
syns = KC_Syns(str, root);
numinfo = char(syns.ShowSynSet);
numinf = regexp(numinfo,' ','split');
if size(numinf,2) == 1;
    num = [];
else
    num = str2num(numinf{2});
end


function sepr = split_all(all)
id_sepr = regexp(all, '#');
n_sepr = numel(id_sepr);
sepr = cell(n_sepr,1);
for i_all = 1:n_sepr-1
    sepr{i_all} = all(id_sepr(i_all)+1 : id_sepr(i_all+1)-1);
end
sepr{n_sepr} = all(id_sepr(n_sepr)+1: end);
        
        