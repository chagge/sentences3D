function [feature] = gen_feature(dataset, bias)
data_globals;
feat_cls = load(WORD_FEATURE_REDUCED);
feat_cls = feat_cls.feature;
ndata = numel(dataset);
feature_word = {};
feature_bias = [];
for i_use = 1:8
%     feature_tag = [feature_tag; feat_cls(i_use).tag];
    feature_word = [feature_word; feat_cls(i_use).word(:,1)]; %#ok<*AGROW>
    n = numel(feat_cls(i_use).word(:,1));
    feature_bias = [feature_bias; ones(n,1) * bias(i_use)];
end

feature_num = numel(feature_word);
feature = zeros(feature_num, ndata);
nsce = numel(feat_cls(9).word);
temp = zeros(nsce,ndata);

% try
for idata = 1: ndata
    infofile = fullfile(INFO_DIR, sprintf('in%04d.mat',dataset(idata)));
    annot = load(infofile);
    desc_num = numel(annot.descriptions);
    for i_desc = 1:desc_num
        sent_num = numel(annot.descriptions(i_desc).tag);
        for i_sent = 1:sent_num
            word_num = size(annot.descriptions(i_desc).tag{i_sent},1);
            for i_word = 1:word_num
                id = find(strcmp(feature_word, annot.descriptions(i_desc).tag{i_sent}{i_word,1}));
                if isempty(id)
                    continue;
                end
                feature(id, idata) = feature_bias(id);
            end            
        end
        %scene type feature
        tid = regexp(annot.descriptions(i_desc).text,feat_cls(9).word);
        for ise = 1:nsce
            if ~isempty(tid{ise})
                temp(ise,idata) = numel(tid{ise}) * bias(9);
            end
        end
    end
end
feature = [feature; temp];
feature = feature/max(max(feature));
% catch
%     a = 1;
% end