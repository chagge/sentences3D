function stat_reduce
datadir = '/Users/kongchen/sentences3D/NYU';
featurefile = fullfile(datadir, sprintf('word_feature.mat'));
destfile = fullfile(datadir, sprintf('word_feature_reduced.mat'));
scefile = fullfile(datadir, sprintf('scene_classes.mat'));
scecls = load(scefile);
scecls = scecls.classes';
scecls = strrep(scecls, '_', ' ');

feature = load(featurefile);
feature = feature.feature;
n_feat = numel(feature);
bias_num =3;
% try
reduce_cls = [1, 3, 6, 7, 8, 10, 11, 13, 15, 16, 17, 18, 19, 20, 22,23, 25:36];

bias_feat = 0;
for i_feat = 1:n_feat
    if ~isempty(find(reduce_cls == i_feat,1))
        feature = feature([1:i_feat-bias_feat-1,i_feat-bias_feat+1:end]);
        bias_feat = bias_feat + 1;
        continue;
    end
    n_word = size(feature(i_feat-bias_feat).word,1);
    bias_word = 0;
    for i_word = 1:n_word        
        if feature(i_feat-bias_feat).word{i_word-bias_word,2} < bias_num
            feature(i_feat-bias_feat).word = feature(i_feat-bias_feat).word(...
                [1:i_word-bias_word-1,i_word-bias_word+1:end],:);
            bias_word = bias_word + 1;
        end
    end
end
temp.tag = 'SCE';
temp.word = scecls;
feature = [feature,temp];
% catch
%     a = 1;
% end
save(destfile,'feature','reduce_cls','bias_num');