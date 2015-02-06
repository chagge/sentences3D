function C = svm_c_matrix

data_globals;

labeled = get_labeled('INFO_DIR');
dataset = load(SPLIT_FILE);
train = [dataset.train; dataset.val(1:100)];
val = dataset.val(101:end);
test = dataset.test;
all = [train; val; test];
train = intersect(train, labeled);
test = intersect(test, labeled);
val = intersect(val, labeled);


gt = load(SCENE_CLASSES);
classes = gt.classes;
gt = gt.class_labels;



% loop_sample =1000;
Cs = (0.5:0.5:20) * 10;
Gs = 0.0050;
Ts = 2;

% for i_sample = 1:loop_sample
    bias = ones(1, 9);
%     bias = randsample(0:4,9,true);
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

    best.models = [];
    best.atv = 0;
    best.av = 0;
    best.ate = 0;
    best.c = 0;
    best.gamma = 0;
    
    for i = 1 : length(Cs)
        c = Cs(i);
        for j = 1 : length(Gs)
            g = Gs(j);
            for k = 1 : length(Ts)
                t = Ts(k);
    
                %g = computeGamma(Xtv);
                %g = 1 / size(Xtv, 1);        
                [~, ~, av, ~, ~] = test_one(instance_matrix_tr, label_vector_tr, ...
                    instance_matrix_vl, label_vector_vl, c, g, t);
                             
                if av > best.av  
                    fprintf('best acc: %0.4f\n', av);
                    [models, atv, ate, predtest, ~] = test_one(...
                        instance_matrix_trvl, label_vector_trvl, ...
                        instance_matrix_te, label_vector_te, c, g, t);
                    best.models = models;
                    best.atv = atv;
                    best.av = av;
                    best.ate = ate;
                    best.c = c;
                    best.gamma = g;
                    best.kernel = t;
                end
%                 fprintf('c = %g, g = %g, t = %d  ==> atv = %.4f, ate = %.4f\n', ...
%                     c, g, t, atv, ate);
            end
        end
    end
    
fprintf('\natv:%g\nav:%g\n',best.atv,best.av);

    %  Pall = mc_svmpredict(best.models, clabels, F.feas, F.olabels);
    
% end

fprintf('-----------\n');
fprintf('best c: %d\n', best.c);
fprintf('ate:%g\n', best.ate);
C = confusionMatrix(label_vector_te, predtest);
fprintf('accuracy: %0.4f\n', mean(diag(C)));
confusion_matrix(C/100, classes);
save(SCENETEXT_BEST_FILE, 'best');


function [models, atv, ate, pred, P] = test_one(Xtv, Ltv, Xte, Lte, c, g, t)

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
