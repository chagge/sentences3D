function color_svm(detector, descriptor, option)

if nargin < 1
    detector = 'densesampling';
    descriptor = 'rgbhistogram';
    option = 'show_wrong_cases';
%     option = 'a';
end


descriptors = {...
    'rgbhistogram',...
    'opponenthistogram',...
    'huehistogram',...
    'nrghistogram',...
    'transformedcolorhistogram',...
    'colormoments',...
    'colormomentinvariants',...
    'sift',...
    'huesift',...
    'hsvsift',...
    'opponentsift',...
    'rgsift',...
    'csift',...
    'rgbsift'};

detectors = {'harrislaplace', 'densesampling'};

if ~ismember(detector, detectors)
    error('%s is a wrong detector\n', detector);
end
if ~ismember(descriptor, descriptors)
    error('%s is a wrong descriptor\n', descriptor);
end
if strcmp(option,'show_wrong_cases')
    to_show_wcases = 1;
else
    to_show_wcases = 0;
end

%root = '/Users/kongchen/sentences3D/';
root = '~/code/sentences3D/code/mycode/color/';
%datadir = fullfile(root, 'NYU');
datadir = root;
colordataset_file = fullfile(datadir, 'descriptors', 'color_dataset_reduced.mat');
if ~exist(colordataset_file, 'file')
    colordataset_file = fullfile(datadir, 'descriptors', 'color_dataset.mat');
    fprintf('using colorlist without being reduced\n');
end

dataset = load(colordataset_file);
colorlist = dataset.colorlist;

[label_vector_tr, instance_matrix_tr, ~, ~] = prepare_all(colorlist, 'train');
[label_vector_vl, instance_matrix_vl, ~, ~] = prepare_all(colorlist, 'val');

best.model = [];
best.ac = 0;
best.c = 0;
best.gamma = 0;

Cs = (0.01:1:50);
Gs = (0.01:1:50);
disp('Model training...')
for ic = 1:numel(Cs)
    c = Cs(ic);
    for ig = 1:numel(Gs)
        g = Gs(ig);
        [models, clabels] = kc_svmtrain(instance_matrix_tr, label_vector_tr, c, g, 2);
        [~, accuracy_val, ~] = kc_svmpredict(models, clabels, instance_matrix_vl, label_vector_vl);
        if accuracy_val > best.ac
            best.ac = accuracy_val;
            best.model = models;
            best.c = c;
            best.gamma = g;
        end            
    end
end 
disp('Model prepared')
%     fprintf('%s\nbest c: %f, best g: %f val accuracy: %f\n',colorlist(i_color).name, best.c, best.gamma, best.ac);
[label_vector_te, instance_matrix_te, imgs, segs] = prepare_all(colorlist, 'test');
[~, ~, predict] = kc_svmpredict(models, clabels, instance_matrix_te, label_vector_te);
%     if isempty(find(predict == 1, 1))
%         fprintf('All are predicted as negative!! SHIT!!!!\n\n');
%     end


num_color = numel(colorlist);
classes = cell(num_color, 1);
for i_color = 1:num_color
    classes{i_color} = colorlist(i_color).name;
end

if to_show_wcases
    show_wrong(predict, label_vector_te, imgs, segs, classes, datadir);
end

C = confusionMatrix(label_vector_te', predict);
fprintf('accuracy: %0.4f\n', mean(diag(C)));
confusion_matrix(C/100, classes);



function [label_vector, instance_matrix, imgs, segs] = prepare_all(colorlist, set_name)
sets = {'train', 'val', 'test'};
if ~ismember(set_name, sets)
    error('Wrong set name. Set Names should be train, val, or test. As set name is %s.', set_name);
end
label_vector = [];
instance_matrix = [];
imgs = [];
segs = {};
for i_colorlist = 1:numel(colorlist)
    color = colorlist(i_colorlist);
    
    f = color.feature_vector / max(max(color.feature_vector));
    
    num_set = numel(color.(set_name));
        label = ones(1, num_set)*i_colorlist;
    feature = f(:, color.(set_name));
    if numel(label) ~= size(feature, 2)
        error('size of label are not complitable with size of feature.');
    end
    label_vector = [label_vector, label]; %#ok<*AGROW>
    instance_matrix = [instance_matrix, feature];
    if strcmp(set_name, 'test')
        imgs = [imgs; color.place(color.test)];
        segs = [segs; color.seg(color.test)];
    end
end

function show_wrong(predict, label_vector_te, imgs, segs, classes, datadir)
wrong_cases = find((predict ~= label_vector_te') == 1);
num_wcases = numel(wrong_cases);
for i = 1:num_wcases
    wcase = wrong_cases(i);
%     subplot(1, num_wcases, i);
    name = [classes{label_vector_te(wcase)} ,' is confused with ', classes{predict(wcase)}];
    figure('name', name);
    mask = uint8(roipoly(zeros(480,640), segs{wcase}(:, 1), segs{wcase}(:, 2)));
    mask = repmat(mask, [1,1,3]);
    im = imread(fullfile(datadir, 'images', sprintf('%04d.jpg', imgs(wcase))));
    im = im .* mask + uint8(ones(480, 640, 3) * 255 .* (mask == 0));
    imshow(im);
    pause;
end