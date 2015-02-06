function colorlist = stati_color_annotation(option)



datadir = '/Users/kongchen/sentences3D/NYU';
info_dir = fullfile(datadir, 'descriptions_info');
split_file = fullfile(datadir, 'split.mat');
histogram_adj_class_file = fullfile(datadir, 'histogram_adj_class.mat');


if nargin >0 && strcmp(option, 'reduce')
    reduce = [1:4,1,5,6,1,6,0,6,1,0,0,4,0,0,0,1,0,0,0,0];
    origin = [1:4,6,7];
    colorlist_file = fullfile(datadir, 'descriptors', 'colorlist_annotation_reduced.mat');
else
    reduce = (1:23);
    origin = (1:23);
    colorlist_file = fullfile(datadir, 'descriptors', 'colorlist_annotation.mat');
end
% objclass_file = fullfile(datadir, 'classes_reduced.mat');
% dataset_file = fullfile(datadir, 'nyu_depth_v2_labeled.mat');

% dataset = load(dataset_file);

labeled = [1:800, 1341:1449];



split = load(split_file);
train = split.train;
val = split.val;
test = split.test;
dataset = [train; val; test];
dataset = intersect(labeled, dataset);

hist_adj_cls = load(histogram_adj_class_file);
hist_color = hist_adj_cls.his_color;
% objcls = load(objclass_file);
% num_objcls = numel(objcls.classes);

colornames = {};

for i_cls = 1:size(hist_color,1)
    if ~ismember(i_cls, origin)
        continue;
    end
    colornames = [colornames, hist_color{i_cls,1}]; %#ok<*AGROW>
    colorlist(reduce(i_cls)).name = hist_color{i_cls,1};
    colorlist(reduce(i_cls)).place = [];
    colorlist(reduce(i_cls)).object = {};
    colorlist(reduce(i_cls)).seg = {};
    colorlist(reduce(i_cls)).num_appearance = 0;
    colorlist(reduce(i_cls)).brightness = {};
    colorlist(reduce(i_cls)).difficult = [];
end

for i_sce = 1:numel(dataset)
    info_file = fullfile(info_dir, sprintf('in%04d.mat', dataset(i_sce)));
    annotation = load(info_file);
    segs = annotation.seg;  
    colors = annotation.color;
    num_seg = numel(segs);
    if isempty(colors)
        continue;
    end
    for i_seg = 1:num_seg
        seg = segs{i_seg};
        color = colors(i_seg);
        clcls = find(strcmp(color.name, colornames));
        if isempty(clcls)
            continue;
        end
        colorlist(clcls).place = [colorlist(clcls).place; dataset(i_sce)];
        colorlist(clcls).seg = [colorlist(clcls).seg; seg];
        colorlist(clcls).num_appearance = colorlist(clcls).num_appearance + 1;
        colorlist(clcls).brightness = [colorlist(clcls).brightness; color.brightness];
        colorlist(clcls).difficult = [colorlist(clcls).difficult; color.difficult];
    end
end
save(colorlist_file, 'colorlist');
