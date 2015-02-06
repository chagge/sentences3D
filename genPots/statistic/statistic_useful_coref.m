function statistic_useful_coref()
data_globals;
num_sce = 1449;
classes = load(CLASS_FINAL);
num_classes = numel(classes.classes);
size_nouns = zeros(num_classes, 1);
size_coref = zeros(num_classes, 1);

for i_sce = 1:num_sce
    file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    if ~exist(file, 'file')
        continue;
    end
    info = load(file);
    if isempty(info.descriptions)
        continue;
    end
    nouns = info.descriptions.noun_final;
    num_nouns = numel(nouns);
    for i_nouns = 1:num_nouns
        noun = nouns(i_nouns);
        size_nouns(noun.class_id_final) = size_nouns(noun.class_id_final) + 1;
        try
        if ~isempty(noun.coref)
            size_coref(noun.class_id_final) = ...
                size_coref(noun.class_id_final) + 1;
        end
        catch
            fprintf('%d\n', i_sce);
        end
    end
end
ratio_classes = size_coref ./ size_nouns;
ratio_all = sum(size_coref) / sum(size_nouns);
save(STATISTIC_COREF, 'size_nouns', 'size_coref', 'ratio_classes', 'ratio_all');
fprintf('number of nouns in each final classes:\n');
fprintf('   %d', size_nouns);
fprintf('\n');
fprintf('number of nouns with coref in each final classes:\n');
fprintf('   %d', size_coref);
fprintf('\n');
fprintf('coref/noun in each final classes:\n');
fprintf('   %0.4f', ratio_classes);
fprintf('\n');
fprintf('coref/noun for all nouns: %0.4f\n', ratio_all);