function paper_statistic(objty)
if nargin < 1
    objty = 'gt';
end
data_globals;
nnoun = zeros(1449, 1);
npronoun = zeros(1449, 1);
human_acc = load(HUMAN_FILE);
scene_class = load(SCENE_CLASSES);
for i_sce = 1:1449
    if mod(i_sce, 100) == 0
        fprintf('doing %d\n', i_sce);
    end
    info = load(fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce)));
    nnoun(i_sce) = info.descriptions.num_noun_final;
    npronoun(i_sce) = info.descriptions.num_pronoun;
end
fprintf('Statistic:\n')
fprintf('   how many nouns of interest per description: %0.4f\n', sum(nnoun)/1449);
fprintf('   how many pronouns per description: %0.4f\n', sum(npronoun)/1449);
fprintf('   how many times a scene is mentioned in a description: %d / 1449 = %0.4f%%\n', ...
    numel(human_acc.available), numel(human_acc.available)/1449 * 100);
fprintf('   how many times the scene is correct: %d / %d = %0.4f%%\n', ...
    numel(find(human_acc.predict(human_acc.available) == scene_class.class_labels(human_acc.available))), ...
    numel(human_acc.available), ...
    numel(find(human_acc.predict(human_acc.available) == scene_class.class_labels(human_acc.available)))/ ...
    numel(human_acc.available) * 100);