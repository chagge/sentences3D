function gen_codebook(descriptor, ac)
if nargin < 1
    descriptor = 'rgbhistogram';
end

if nargin < 2
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

if ~ismember(descriptor, descriptors)
    error('%s is a wrong descriptor\n', descriptor);
end

nyu_globals;
datadir = DATASET_ROOT;
split_file = fullfile(datadir, 'split.mat');
dataset_dir = fullfile(datadir, 'descriptors', descriptor);
visual_dir = fullfile(datadir, 'descriptors',[descriptor, '_visual']);
if ~exist(visual_dir, 'dir')
    mkdir(visual_dir);
end
dest_file = fullfile(visual_dir, 'codebook.mat');
% text_dir = fullfile(datadir, 'descriptors', [descriptor, '_final']);
% if ~exist(text_dir, 'dir')
%     mkdir(text_dir);
% end
% text_file = fullfile(text_dir, 'codebook.text');


% vl_setup_file = fullfile(root, 'code/vlfeat-0.9.17/toolbox/vl_setup');
% run (vl_setup_file);

split = load(split_file);
train = split.train;
val = split.val;
test = split.test;
dataset = [train; val; test];

num_images = 50000;
images = randsample(dataset, num_images, true);

data_all = [];
numClusters = 300;

disp('preparing data...')
for i_data = 1:numel(dataset)
    if mod(i_data, 200) == 0
        fprintf('Processed %d / %d\n', i_data, numel(dataset))
    end
    num_points_s = numel(find(images == dataset(i_data)));
    if ~num_points_s
        continue
    end    
    data_file = fullfile(dataset_dir, sprintf('%04d.text', dataset(i_data)));
    text = textread(data_file, '%s', 'delimiter', '\n'); %#ok<REMFF1>
    size_feature = str2num(text{2});
    num_points = str2num(text{3});
    points = randsample(1:num_points, num_points_s, true);
    for i_point = 1:num_points_s
        f_v_s = text{points(i_point)+3};
        sep = regexp(f_v_s, ';');
        f_v_s = f_v_s(sep(1)+1:sep(2)-1);
        f_v = str2num(f_v_s)';
        if numel(f_v) ~= size_feature
            error('wrong size of feature in %4d.text, the %d-th points', i_data, points(i_point));
        end
        f_v = uint8(f_v * ac);
        data_all = [data_all, f_v]; %#ok<AGROW>
    end
end

if size(data_all, 1) ~= size_feature
    error('feature has a wrong size!');
end
if size(data_all, 2) ~= num_images
    error('no enough data!');
end
disp('k-means...')
[centers, assignments] = vl_ikmeans(data_all, numClusters); %#ok<ASGLU,NASGU>

% record points
data_file = fullfile(dataset_dir, sprintf('%04d.text', dataset(i_data)));
text = textread(data_file, '%s', 'delimiter', '\n'); %#ok<REMFF1>
points = zeros(numel(text)-3,2);
for i_text = 4:numel(text)
    id_space = regexp(text{i_text},' ');
    x = text{i_text}(id_space(1)+1:id_space(2)-1);
    y = text{i_text}(id_space(2)+1:id_space(3)-1);
    points(i_text-3,:) = [str2num(x), str2num(y)];
end

save(dest_file, 'centers', 'assignments', 'points');

% generate codebook in text format
% fid = fopen(text_file,'w+');
% fprintf(fid, 'KOEN1\n%d\n%d\n', size_feature, numClusters);
% for i = 1:numClusters
%     fprintf(fid, '<CIRCLE 0 0 0 0 0>;');
%     for j = 1:size_feature
%         fprintf(fid, ' %f', centers(j,i));
%     end
%     fprintf(fid, ';\n');
% end
% fclose(fid);
