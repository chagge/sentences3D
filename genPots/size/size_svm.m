function size_svm(objty, overwrite)

if nargin < 1
    objty = 'gt';
end;
if nargin < 2
    overwrite = 0;
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

labeled = (1:1449)';
train = intersect(labeled, train);
val = intersect(labeled, val);
test = intersect(labeled, test);

disp('Preparing Train Set...');
file = fullfile(SIZE_DIR, 'train.mat');
if exist([file overwrite], 'file')
    fprintf('Load from file:%s\n', file);
    load(file);
else
    [label_vector_tr, instance_matrix_tr] = gen_data_size(objty, train);
    save(file, 'label_vector_tr', 'instance_matrix_tr');
end

disp('Preparing Val Set...');
file = fullfile(SIZE_DIR, 'val.mat');
if exist([file overwrite], 'file')
    fprintf('Load from file:%s\n', file);
    load(file);
else
    [label_vector_vl, instance_matrix_vl] = gen_data_size(objty, val);
    save(file, 'label_vector_vl', 'instance_matrix_vl');
end

disp('Preparing Test Set...');
file = fullfile(SIZE_DIR, 'test.mat');
if exist([file overwrite], 'file')
    fprintf('Load from file:%s\n', file);
    load(file);
else
    [label_vector_te, instance_matrix_te] = gen_data_size(objty, test);
    save(file, 'label_vector_te', 'instance_matrix_te');
end

label_vector_trvl = cell(2, 1);
instance_matrix_trvl = cell(2, 1);
for i = 1 : 2
 label_vector_trvl{i} = [label_vector_tr{i}; label_vector_vl{i}];
 instance_matrix_trvl{i} = [instance_matrix_tr{i}; instance_matrix_vl{i}];
end;

disp('Balancing Data Set...');
for i = 1 : 2
[label_vector_tr{i}, instance_matrix_tr{i}] = take_proper(label_vector_tr{i}, instance_matrix_tr{i});
[label_vector_vl{i}, instance_matrix_vl{i}] = take_proper(label_vector_vl{i}, instance_matrix_vl{i});
[label_vector_trvl{i}, instance_matrix_trvl{i}] = take_proper(label_vector_trvl{i}, instance_matrix_trvl{i});
if 1
[label_vector_tr{i}, instance_matrix_tr{i}, norm] = balance_a_size(label_vector_tr{i}, instance_matrix_tr{i}, 1);
[label_vector_vl{i}, instance_matrix_vl{i}] = balance_a_size(label_vector_vl{i}, instance_matrix_vl{i});
[label_vector_trvl{i}, instance_matrix_trvl{i}, norm] = balance_a_size(label_vector_trvl{i}, instance_matrix_trvl{i}, 1);
[label_vector_te{i}, instance_matrix_te{i}] = balance_a_size(label_vector_te{i}, instance_matrix_te{i});
end;
end;

Cs = (0.01:1:10);%40);
Gs = (0.01:1:10);%40);
disp('Model training...')
sizes = {'small', 'big'};
best = cell(2, 1);
for i = 1 : length(label_vector_tr)
fprintf('training %s\n', sizes{i});
best{i}.model = [];
best{i}.ac = 0;
best{i}.c = 0;
best{i}.gamma = 0;
best{i}.C = [];
for ic = 1:numel(Cs)
    c = Cs(ic);
    for ig = 1:numel(Gs)
        g = Gs(ig);
        params = sprintf('-c %g -g %g -t %d -q -d 2', c, g, 2);
        model = svmtrain(label_vector_tr{i}, instance_matrix_tr{i}, params);
        [predict, ~, ~] = svmpredict(label_vector_vl{i}, instance_matrix_vl{i}, model, '-q');
        Ci = confusionMatrix(label_vector_vl{i}, predict);
        acc = mean(diag(Ci));
        if acc > best{i}.ac
            fprintf('acc on val: %0.4f   (c=%0.4f, gamma = %0.4f)\n', acc, c, g);
            best{i}.ac = acc;
            best{i}.model = model;
            best{i}.c = c;
            best{i}.gamma = g;
            best{i}.C = Ci;
        end            
    end
end 
best{i}.C
disp('Model prepared')
params = sprintf('-c %g -g %g -t %d -q -d 2', best{i}.c, best{i}.gamma, 2);
best{i}.model = svmtrain(label_vector_trvl{i}, instance_matrix_trvl{i}, params);
%
%     fprintf('%s\nbest c: %f, best g: %f val accuracy: %f\n',colorlist(i_color).name, best.c, best.gamma, best.ac);
[predict, accuracy, probability] = svmpredict(label_vector_te{i}, instance_matrix_te{i}, best{i}.model, '-q'); %#ok<NASGU,ASGLU>
C{i} = confusionMatrix(label_vector_te{i}, predict);
acc(i) = mean(diag(C{i}));
fprintf('accuracy: %g\n', acc(i));
end;

save(SIZE_BEST_MODELS, 'best', 'norm');
file = fullfile(SIZE_DIR, 'result.mat');
save(file, 'acc',  'C');

classes = {'small', 'big'};

%C = confusionMatrix(label_vector_te, pred);
%fprintf('accuracy: %0.4f\n', mean(diag(C)));
%confusion_matrix(C/100, classes);


function [label_vector_tr, instance_matrix_tr] = take_proper(label_vector_tr, instance_matrix_tr)

ind = find(label_vector_tr~=0);
label_vector_tr = label_vector_tr(ind);
instance_matrix_tr = instance_matrix_tr(ind, :);