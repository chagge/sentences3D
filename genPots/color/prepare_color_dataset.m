function prepare_color_dataset(detector, descriptor, overwrite)

if nargin < 1 || isempty(detector)
    detector = 'densesampling';
end;

if nargin < 2
    descriptor = 'rgbhistogram';
end

if nargin < 3
    overwrite = 0;
end; 

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

disp('EXTRACTING DESCRIPTORS');
fprintf('using config: detector = %s, descriptor = %s\n', detector, descriptor)
nyu_globals;
outdir = fullfile(FEATURES_DIR, [descriptor, '_origin']);
if ~exist(outdir, 'dir'), mkdir(outdir); end;
images_dir = IMAGES_DIR;

datasetinfo = get_dataset_info('all');
dataset = datasetinfo.all;
%ext = '.text'; outputformat = [];
ext = ''; outputformat = 'binary';


for i_img = 1:numel(dataset)
    img_file = fullfile(images_dir, sprintf('%04d.jpg', dataset(i_img)));
    output_file = fullfile(outdir,...
        sprintf('%04d%s', dataset(i_img), ext));
    if exist(output_file, 'file') & overwrite == 0
        continue;
    end;
    command = [ ...
        './colorDescriptor ', img_file,...
        ' --detector ', detector,...
        ' --descriptor ', descriptor,...
        ' --ds_spacing 5',...
        ' --output ', output_file];
    if ~isempty(outputformat)
        command = [command ' --outputFormat ' outputformat];
    end;
    unix(command);
end

fprintf('... finished!\n');