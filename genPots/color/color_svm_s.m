function color_svm_s(descriptor, option)

if nargin < 1
       descriptor = {'rgbhistogram'}; 
end;
if nargin < 2
    option = 'show_wrong_cases';
%     option = 'a';
end

if strcmp(option,'show_wrong_cases')
    to_show_wcases = 1;
else
    to_show_wcases = 0;
end

nyu_globals;
colordataset_file = COLORDATASET_FILE;
bestmodel_file = fullfile(FEATURES_DIR, 'best_color_models.mat');

dataset = load(colordataset_file);
colorlist = dataset.colorlist;
colorlist = mergeColors(colorlist);
colorlist = stackFeatures(colorlist, descriptor);

[label_vector_tr, instance_matrix_tr, ~, ~] = prepare_all(colorlist, 'train');
[label_vector_vl, instance_matrix_vl, ~, ~] = prepare_all(colorlist, 'val');

best.models = [];
best.clabels = [];
best.ac = 0;
best.c = 0;
best.gamma = 0;

%Cs = (0.01:1:50);
%Gs = (0.01:1:50);
Cs = (0.01:1:50);
Gs = (0.01);
disp('Model training...')
for ic = 1:numel(Cs)
    c = Cs(ic);
    for ig = 1:numel(Gs)
        g = Gs(ig);
        [models, clabels] = kc_svmtrain(instance_matrix_tr, label_vector_tr, c, g, 0);
        [~, ~, predict] = kc_svmpredict(models, clabels, instance_matrix_vl, label_vector_vl);
        C = confusionMatrix(label_vector_vl', predict);
        accuracy_val = mean(diag(C));
        if accuracy_val > best.ac
            best.ac = accuracy_val;
            best.models = models;
            best.clabels = clabels;
            best.c = c;
            best.gamma = g;
        end            
    end
end 

disp('Model prepared')
%     fprintf('%s\nbest c: %f, best g: %f val accuracy: %f\n',colorlist(i_color).name, best.c, best.gamma, best.ac);
[label_vector_te, instance_matrix_te, imgs, segs] = prepare_all(colorlist, 'test');
[~, ~, predict] = kc_svmpredict(best.models, best.clabels, instance_matrix_te, label_vector_te);
%     if isempty(find(predict == 1, 1))
%         fprintf('All are predicted as negative!! SHIT!!!!\n\n');
%     end


num_color = numel(colorlist);
classes = cell(num_color, 1);
for i_color = 1:num_color
    classes{i_color} = colorlist(i_color).name;
end

if to_show_wcases
   % show_wrong(predict, label_vector_te, imgs, segs, classes, datadir);
end

save(bestmodel_file, 'best');

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
    feat_vector = double(color.feature_vector);
    %f = feat_vector ./ repmat(sum(feat_vector.^2, 1).^0.5, [size(feat_vector, 1), 1]);
    
    %f = double(color.feature_vector) / max(max(double(color.feature_vector)));
    f = feat_vector;
    
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


function colorlistout = mergeColors(colorlist)

nyu_globals;
names = arrayfun(@(x)x.name, colorlist, 'UniformOutput', 0);
colorlistout = [];

for i = 1 : length(colors)
    cols = colors(i).name;
    ind = strmatch(cols{1}, names, 'exact');
    colorlistout(i).place = colorlist(ind).place;
    colorlistout(i).seg = colorlist(ind).seg;
    colorlistout(i).train = colorlist(ind).train;
    colorlistout(i).val = colorlist(ind).val;
    colorlistout(i).test = colorlist(ind).test;
    colorlistout(i).name = colorlist(ind).name;
    colorlistout(i).brightness = colorlist(ind).brightness;
    colorlistout(i).object = colorlist(ind).object;
    colorlistout(i).num_appearance = colorlist(ind).num_appearance;  
    colorlistout(i).features = colorlist(ind).features;
    
    for j = 2 : length(cols)
        colorlistout(i).place = [colorlistout(i).place; colorlist(ind).place];
        colorlistout(i).seg = [colorlistout(i).seg; colorlist(ind).seg];
        colorlistout(i).train = [colorlistout(i).train; length(colorlistout(i).train) + colorlist(ind).train];
        colorlistout(i).val = [colorlistout(i).val; length(colorlistout(i).val) + colorlist(ind).val];
        colorlistout(i).test = [colorlistout(i).test; length(colorlistout(i).test) + colorlist(ind).test];
        colorlistout(i).brightness = [colorlistout(i).brightness; colorlist(ind).brightness];
        colorlistout(i).object = [colorlistout(i).object; colorlist(ind).object];
        for k = 1 : length(colorlist(ind).features)
           colorlistout(i).features(k).feature_vector = [colorlistout(i).features(k).feature_vector, colorlist(ind).features(k).feature_vector];
        end;
    end;
end;

function colorlist = stackFeatures(colorlist, descriptors)

nrm = 'l2';

for i = 1 : length(colorlist)
    colorlist(i).feature_vector = [];
    for j = 1 : length(colorlist(i).features)
        if ~isempty(strmatch(colorlist(i).features(j).name, descriptors))
            f = colorlist(i).features(j).feature_vector;
            switch nrm
                case 'l2'
                   f = f ./ repmat(sum(f.^2, 1).^0.5 + eps, [size(f, 1), 1]); 
                case 'l1'
                   f = f ./ repmat(sum(f, 1) + eps, [size(f, 1), 1]);
            end;
            colorlist(i).feature_vector = [colorlist(i).feature_vector; f];
        end;
    end;
end;