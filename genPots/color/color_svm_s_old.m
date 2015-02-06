function color_svm_s(detector, descriptor, option)

if nargin < 1
    detector = 'densesampling';
    descriptor = 'rgbhistogram';
%     option = 'show_wrong_cases';
    option = 'a';
end
% 
% if nargin < 3
%     ac = 1000;
% end

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
% split_file = fullfile(datadir, 'split.mat');
% dataset_dir = fullfile(datadir, 'descriptors', descriptor);
% visual_dir = fullfile(datadir, 'descriptors', [descriptor, '_visual']);
% images_dir = fullfile(datadir, 'images');
% codebook_file = fullfile(visual_dir, 'codebook.mat');
% dest_file = fullfile(datadir, 'descriptors', 'color_dataset.mat');
colordataset_file = fullfile(datadir, 'descriptors', 'color_dataset_reduced.mat');
if ~exist(colordataset_file, 'file')
    colordataset_file = fullfile(datadir, 'descriptors', 'color_dataset.mat');
    fprintf('using colorlist without being reduced\n');
end
% split = load(split_file);
% train = split.train;
% val = split.val;
% test = split.test;
% codebook = load(codebook_file);
dataset = load(colordataset_file);
colorlist = dataset.colorlist;

% for i_color = 1:2

    [label_vector_tr, instance_matrix_tr, ~, ~] = prepare_all(colorlist, 'train');
    [label_vector_vl, instance_matrix_vl, ~, ~] = prepare_all(colorlist, 'val');
    
    best.model = [];
    best.ac = 0;
    best.c = 0;
    best.gamma = 0;
    
    Cs = (0.01:1:50);
    Gs = (0.01:1:50);
    
    for ic = 1:numel(Cs)
        c = Cs(ic);
        for ig = 1:numel(Gs)
            for i_color = 1:numel(colorlist)
                g = Gs(ig);
                options = sprintf('-c %g -g %g -q -b 1', c, g);
                label_vector_tr_bin = 2 * double(label_vector_tr' == i_color) - 1;
                model = svmtrain(label_vector_tr_bin, instance_matrix_tr', options);
    %             fprintf('c:%f, g:%f ---> ', c, g);
                [a1, accuracy, scores] = svmpredict(label_vector_vl', instance_matrix_vl', model, '-q -b 1');
                if accuracy(1) > best.ac
                    best.ac = accuracy(1);
                    best.model = model;
                    best.c = c;
                    best.gamma = g;
                end
            end;
        end
    end   
    fprintf('%s\nbest c: %f, best g: %f val accuracy: %f\n',colorlist(i_color).name, best.c, best.gamma, best.ac);
    [label_vector_te, instance_matrix_te, imgs, segs] = prepare_all(colorlist, i_color, 'test');
    predict = svmpredict(label_vector_te', instance_matrix_te', best.model);
    if isempty(find(predict == 1, 1))
        fprintf('All are predicted as negative!! SHIT!!!!\n\n');
    end
    if to_show_wcases
        show_wrong(predict, label_vector_te, imgs, segs, colorlist(i_color).name, datadir);
    end
%     pause;


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
    label = i_colorlist * ones(1, num_set);
%     feature = color.feature_vector(:, color.(set_name));
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


function show_wrong(predict, label_vector_te, imgs, segs, color, datadir)
wrong_cases = find((predict ~= label_vector_te') == 1);
num_wcases = numel(wrong_cases);
for i = 1:num_wcases
    wcase = wrong_cases(i);
%     subplot(1, num_wcases, i);
    figure;
    title(sprintf('%s --> wrong case: %d', color, imgs(wcase)));
    mask = uint8(roipoly(zeros(480,640), segs{wcase}(:, 1), segs{wcase}(:, 2)));
    im = imread(fullfile(datadir, 'images', sprintf('%04d.jpg', imgs(wcase))));
    im = im .* repmat(mask, [1,1,3]);
    imshow(im);
end