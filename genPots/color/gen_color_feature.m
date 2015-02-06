function gen_color_feature(detector, descriptor, ac)

if nargin < 2
    detector = 'densesampling';
    descriptor = 'rgbhistogram';
end

if nargin < 3
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
dest_file = fullfile(visual_dir, 'assignment.mat');

split = load(split_file);
train = split.train;
val = split.val;
test = split.test;
dataset = [train; val; test];
codebook = load(codebook_file);
assignment = cell(max(dataset),1);

for i_img = 1:numel(dataset)
    if mod(i_img, 200) == 0
        fprintf('Processed %d / %d\n', i_img, numel(dataset))
    end
    output_file = fullfile(dataset_dir, sprintf('%04d.text', dataset(i_img)));
    text = textread(output_file, '%s', 'delimiter', '\n'); %#ok<REMFF1>
    size_feature = str2num(text{2});
    num_points = str2num(text{3});
    if num_points ~= size(codebook.points, 1)
        error('wrong number of points in image%d', dataset(i_img));
    end
    assignment{dataset(i_img)} = zeros(num_points,1);
    for i_point = 1:num_points
        f_v_s = text{i_point+3};
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
        assignment{dataset(i_img)}(i_point) = assign;
    end
end

save(dest_file, 'assignment');