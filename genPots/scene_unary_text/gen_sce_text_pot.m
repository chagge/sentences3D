function gen_sce_text_pot(objty) %#ok<INUSD>
data_globals;

best = load(SCENETEXT_BEST_FILE);
best = best.best;

dataset = load(SPLIT_FILE);
train = dataset.train;
val = dataset.val;
test = dataset.test;
all = [train; val; test];

gt = load(SCENE_CLASSES);
classes = gt.classes;
gt = gt.class_labels;

bias = ones(1, 9);
fprintf(' %d ',bias);
fprintf('\nComputing...');
instance_matrix_tr = gen_feature(train, bias);
label_vector_tr = gt(train);
if ~isempty(val)
   instance_matrix_vl = gen_feature(val, bias);
   label_vector_vl = gt(val);
end;
instance_matrix_te = gen_feature(test, bias);
label_vector_te = gt(test);
instance_matrix_all = [instance_matrix_tr, instance_matrix_vl, instance_matrix_te];
label_vector_all = [label_vector_tr; label_vector_vl; label_vector_te];
instance_matrix_trvl = [instance_matrix_tr, instance_matrix_vl];
label_vector_trvl = [label_vector_tr; label_vector_vl];

[models, clabels, ~, ~, pred, P] = test_one(instance_matrix_trvl, label_vector_trvl,...
    instance_matrix_all, label_vector_all, best.c, best.gamma, best.kernel); 
scene_text_pot = zeros(numel(all), numel(classes));
labeled = [train; val; test];
scene_text_pot(labeled,:) = P; %#ok<NASGU>
[~, ate, predte] = kc_svmpredict(models, clabels, instance_matrix_te, label_vector_te);
fprintf('ate: %0.4f\n', ate);
C = confusionMatrix(label_vector_te, predte);
fprintf('accuracy: %0.4f\n', mean(diag(C)));
save(SCENETEXT_FILE, 'scene_text_pot', 'gt');



function [models, clabels, atv, ate, pred, P] = test_one(Xtv, Ltv, Xte, Lte, c, g, t)

[models, clabels] = kc_svmtrain(Xtv, Ltv, c, g, t);

[~, atv, ~] = kc_svmpredict(models, clabels, Xtv, Ltv);
[P, ate, pred] = kc_svmpredict(models, clabels, Xte, Lte);

% function g = computeGamma(X)
% 
%         X = X';
%         norm1 = sum(X.^2,2);
%         norm2 = sum(X.^2,2);
%         dist = (repmat(norm1 ,1,size(X,1)) + repmat(norm2',size(X,1),1) - 2*X*X');
%         %g=sqrt(mean(dist(:))/2);
%         g = 1 / mean(dist(:));
