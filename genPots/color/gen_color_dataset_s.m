function gen_color_dataset_s(descriptor, overwrite)

nyu_globals;

dest_file = COLORDATASET_FILE;

if exist(dest_file, 'file') & overwrite == 0
    return;
end;

fprintf('PREPARING COLOR FEATURES FOR DATASET\n');
dataset = get_dataset_info('color');

load(COLORLIST_FILE);
names = arrayfun(@(x)x.name, colorlist, 'UniformOutput', 0);
ind = strmatch('notlabeled', names, 'exact');
colorlist(ind) = [];


for i_color = 1:numel(colorlist)        
    color = colorlist(i_color);
    colorlist(i_color).train = kc_intersect(color.place, dataset.train);
    colorlist(i_color).val = kc_intersect(color.place, dataset.val);
    colorlist(i_color).test = kc_intersect(color.place, dataset.test);
    
    for i_desc = 1 : length(descriptor)
        % for i_color = 1:1
        visual_dir = fullfile(FEATURES_DIR, [descriptor{i_desc}, '_codebook']);
        codebookfile = fullfile(visual_dir, 'codebook.mat');
        codebook = load(codebookfile);
        colorlist(i_color).features(i_desc).name = descriptor{i_desc};
        colorlist(i_color).features(i_desc).feature_vector = hist_color(colorlist(i_color), codebook, visual_dir);  
    end
    fprintf('Color %s prepared.\n', color.name);
end;
save(dest_file, 'colorlist');



function feature_vector = hist_color(color, codebook, dataset_dir)
nyu_globals;
num_codes = size(codebook.centers, 2);
feature_vector = zeros(num_codes, size(color.place, 1));
for i_place = 1:color.num_appearance
    i_p = color.place(i_place);
    seg = color.seg{i_place};
    data = load(fullfile(dataset_dir, sprintf('%04d.mat', i_p)));
    [desc, ~] = getFeatMask(seg, data.desc, data.loc);    
    feature_vector(:,i_place) = vl_ikmeanshist(num_codes, desc);
end


function inter_b = kc_intersect(seta,setb)
inter_b = [];
inters = intersect(seta, setb);
for i_inter = 1:numel(inters)
    inter = inters(i_inter);
    i_b = find(seta == inter);
    inter_b = [inter_b; i_b]; %#ok<AGROW>
end