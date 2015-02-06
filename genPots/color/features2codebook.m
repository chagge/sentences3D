function features2codebook(descriptor, overwrite)

if nargin < 1
    descriptor = 'rgbhistogram';
end
if nargin < 2
    overwrite = 0;
end;

nyu_globals;
dataset_dir = fullfile(FEATURES_DIR, [descriptor '_origin']);
visual_dir = fullfile(FEATURES_DIR, [descriptor, '_codebook']);
if ~exist(visual_dir, 'dir')
    mkdir(visual_dir);
end
codebookfile = fullfile(visual_dir, 'codebook.mat');
codebook = load(codebookfile);

datasetinfo = get_dataset_info('all');
dataset = datasetinfo.all;

fprintf('ASSIGNING FEATURES TO CODEBOOK\n');

for i = 1 : length(dataset)
    fprintf('%d/%d\n', i, length(dataset));
    data_file = fullfile(dataset_dir, sprintf('%04d', dataset(i)));
    outfile = fullfile(visual_dir, sprintf('%04d.mat', dataset(i)));
    if exist(outfile, 'file') & overwrite== 0
        continue;
    end;
    [feat, loc] = readFeatFile(data_file);
    feat = uint8(feat * codebook.norm_value);
    desc = vl_ikmeanspush(feat, codebook.centers);
    save(outfile, 'desc', 'loc')
end;

fprintf('... finished!\n');