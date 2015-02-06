function a_cuboid_svm(objty, overwrite)

if nargin < 1
    objty = 'gt';
end;
if nargin < 2
    overwrite = 1;
end;
if overwrite
    overwrite = '1';
else
    overwrite = [];
end;
data_globals;

disp('Data preparing...');
split = load(SPLIT_FILE);
train = split.train;
val = split.val;
test = split.test;

%labeled = get_labeled('INFO_DIR');
labeled = (1:1449)';
train = intersect(labeled, train);
val = intersect(labeled, val);
test = intersect(labeled, test);
%[train, val, test] = re_split(train, val);
if ~strcmp(objty, 'gt')
    A_CUBOID_DIR = fullfile(A_CUBOID_DIR, objty); %#ok<NODEF>
    if ~exist(A_CUBOID_DIR, 'dir')
        mkdir(A_CUBOID_DIR);
    end;
end;

disp('Preparing Train Set...');
file = fullfile(A_CUBOID_DIR, 'train.mat');
if exist([file overwrite], 'file')
    disp('Load from file');
    load(file);
else
    [label_vector_tr, instance_matrix_tr] = gen_data_a_cuboid(train, objty);
    save(file, 'label_vector_tr', 'instance_matrix_tr');
end

disp('Preparing Val Set...');
file = fullfile(A_CUBOID_DIR, 'val.mat');
if exist([file overwrite], 'file')
    disp('Load from file');
    load(file);
else
    [label_vector_vl, instance_matrix_vl] = gen_data_a_cuboid(val, objty);
    save(file, 'label_vector_vl', 'instance_matrix_vl');
end

disp('Preparing Test Set...');
file = fullfile(A_CUBOID_DIR, 'test.mat');
if exist([file '' overwrite], 'file')
    disp('Load from file');
    load(file);
else
    [label_vector_te, instance_matrix_te] = gen_data_a_cuboid(test, objty);
    save(file, 'label_vector_te', 'instance_matrix_te');
end
label_vector_trvl = [label_vector_tr; label_vector_vl];
instance_matrix_trvl = [instance_matrix_tr; instance_matrix_vl];

use_it = 1;
disp('Balancing Data Set...');
[label_vector_tr, instance_matrix_tr] = take_proper(label_vector_tr, instance_matrix_tr, use_it);
[label_vector_vl, instance_matrix_vl] = take_proper(label_vector_vl, instance_matrix_vl, use_it);
[label_vector_trvl, instance_matrix_trvl] = take_proper(label_vector_trvl, instance_matrix_trvl, use_it);
[label_vector_tr, instance_matrix_tr, ~] = balance_a_cuboid(label_vector_tr, instance_matrix_tr, objty, 1);
[label_vector_vl, instance_matrix_vl] = balance_a_cuboid(label_vector_vl, instance_matrix_vl, objty);
[label_vector_trvl, instance_matrix_trvl] = balance_a_cuboid(label_vector_trvl, instance_matrix_trvl, objty);
if ~use_it
ind = find(label_vector_te(:, 2) == 0);
label_vector_te = label_vector_te(ind, :);
instance_matrix_te = instance_matrix_te(ind, :);
end;
label_vector_te = label_vector_te(:, 1);
[label_vector_te, instance_matrix_te] = balance_a_cuboid(label_vector_te, instance_matrix_te, objty);


best.model = [];
best.ac = 0;
best.c = 0;
best.gamma = 0;
Cs = (5:1:10);
Gs = (10:1:50);%50);
disp('Model training...')
for ic = 1:numel(Cs)
    c = Cs(ic);
    for ig = 1:numel(Gs)
        g = Gs(ig);
        params = sprintf('-c %g -g %g -t %d -q -d 2', c, g, 1);
        model = svmtrain(label_vector_tr, instance_matrix_tr, params);
        [predict, ~, ~] = svmpredict(label_vector_vl, instance_matrix_vl, model, '-q');
        C = confusionMatrix(label_vector_vl, predict);
        acc = mean(diag(C));
        if acc > best.ac
            fprintf('acc on val: %0.4f   (c=%0.4f, gamma = %0.4f)\n', acc, c, g);
            best.ac = acc;
            best.model = model;
            best.c = c;
            best.gamma = g;
        end            
    end
end 
disp('Model prepared')
params = sprintf('-c %g -g %g -t %d -q -d 2', best.c, best.gamma, 1);
best.model = svmtrain(label_vector_trvl, instance_matrix_trvl, params);

[predict, accuracy, probability] = svmpredict(label_vector_te, instance_matrix_te, best.model, '-q'); %#ok<NASGU,ASGLU>
C = confusionMatrix(label_vector_te, predict);
acc = mean(diag(C));
fprintf('accuracy: %g\n', acc);
file = fullfile(A_CUBOID_DIR, 'result.mat');
save(CANDIDATE_MODELS_FILE, 'best', 'norm');
save(file, 'predict', 'acc', 'accuracy', 'probability');


function [label_vector_tr, instance_matrix_tr] = take_proper(label_vector_tr, instance_matrix_tr, use_it)

if ~use_it
    ind = find(label_vector_tr(:, 2) == 0);
    label_vector_tr = label_vector_tr(ind, :);
    instance_matrix_tr = instance_matrix_tr(ind, :);
end;
if size(label_vector_tr, 2) > 1
    label_vector_tr = label_vector_tr(:, 1);
end;
ind = find(label_vector_tr~=0);
label_vector_tr = label_vector_tr(ind);
instance_matrix_tr = instance_matrix_tr(ind, :);

