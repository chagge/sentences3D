function dataset = get_dataset_info(name)

nyu_globals;
split = load(SPLIT_FILE);
% objclass_file = fullfile(datadir, 'classes_reduced.mat');
% dataset_file = fullfile(datadir, 'nyu_depth_v2_labeled.mat');

% dataset = load(dataset_file);

switch name
    case 'color'
        labeled = [1:252];
    case 'descriptions'
        labeled = [1:800, 1341:1449];
    otherwise
        labeled = [1:1449];
end;

train = split.train;
val = split.val;
test = split.test;
dataset.all = [train; val; test];
dataset.all = intersect(labeled, dataset.all);
dataset.train = intersect(train, labeled);
dataset.val = intersect(val, labeled);
dataset.test = intersect(test, labeled);