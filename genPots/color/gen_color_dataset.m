function gen_color_dataset(detector, descriptor, ac)

if nargin < 2
    detector = 'densesampling';
    descriptor = 'rgbhistogram';
end

if nargin < 4
    ac = 10000;
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

root = '/Users/kongchen/sentences3D/';
datadir = fullfile(root, 'NYU');
split_file = fullfile(datadir, 'split.mat');
dataset_dir = fullfile(datadir, 'descriptors', descriptor);
visual_dir = fullfile(datadir, 'descriptors', [descriptor, '_visual']);
% images_dir = fullfile(datadir, 'images');
codebook_file = fullfile(visual_dir, 'codebook.mat');
dest_file = fullfile(datadir, 'descriptors', 'color_dataset_reduced.mat');
colorlist_file = fullfile(datadir, 'descriptors', 'colorlist_reduced.mat');
if ~exist(colorlist_file, 'file')
    colorlist_file = fullfile(datadir, 'descriptors', 'colorlist.mat');
    dest_file = fullfile(datadir, 'descriptors', 'color_dataset.mat');
    fprintf('using colorlist without being reduced\n');
end

split = load(split_file);
train = split.train;
val = split.val;
test = split.test;
codebook = load(codebook_file);
colorlist_o = load(colorlist_file);
colorlist_o = colorlist_o.colorlist;

for i_color = 1:numel(colorlist_o)
% for i_color = 1:1
    color = colorlist_o(i_color);
    color.train = kc_intersect(color.place, train);
    color.val = kc_intersect(color.place, val);
    color.test = kc_intersect(color.place, test);
    color = hist_color(color, codebook, dataset_dir, ac);
    colorlist(i_color) = color; %#ok<AGROW,NASGU>
    fprintf('Color %s prepared.\n', color.name);
end
save(dest_file, 'colorlist');



function color = hist_color(color, codebook, dataset_dir, ac)
points = codebook.points;
num_codes = size(codebook.centers, 2);
color.feature_vector = zeros(num_codes, size(color.place, 1));
for i_place = 1:color.num_appearance
    i_p = color.place(i_place);
    seg = color.seg{i_place};
    mask = roipoly(zeros(480,640), seg(:, 1), seg(:, 2));
    [x,y] = find(mask == 1);
    points_mask = [x, y];
    [~,I,~] = intersect(points, points_mask, 'rows');
    points_f = points(I,:);
    assignment = getassignment(dataset_dir, i_p, codebook, points_f, ac);    
    color.feature_vector(:,i_place) = vl_ikmeanshist(num_codes, assignment);
end


function assignment = getassignment(dataset_dir, i_img, codebook, points, ac)
output_file = fullfile(dataset_dir, sprintf('%04d.text', i_img));
text = textread(output_file, '%s', 'delimiter', '\n'); %#ok<REMFF1>
size_feature = str2num(text{2});
num_points = str2num(text{3});
if num_points ~= size(codebook.points, 1)
    error('wrong number of points in image%d', dataset(i_img));
end
assignment = zeros(size(points, 1), 1);
for i_point = 1:size(points, 1)
    f_v_s = text{points(i_point)+3};
    sep = regexp(f_v_s, ';');
    f_v_s = f_v_s(sep(1)+1:sep(2)-1);
    f_v = str2num(f_v_s)';
    if numel(f_v) ~= size_feature
        error('wrong size of feature in %4d.text, the %d-th points', i_data, points(i_point));
    end
    f_v = uint8(f_v * ac);
    assign = vl_ikmeanspush(f_v, codebook.centers);
    if numel(assign) ~= 1
        error('push more than one groups');
    end
    assignment(i_point) = assign;
end

function inter_b = kc_intersect(seta,setb)
inter_b = [];
inters = intersect(seta, setb);
for i_inter = 1:numel(inters)
    inter = inters(i_inter);
    i_b = find(seta == inter);
    inter_b = [inter_b; i_b]; %#ok<AGROW>
end