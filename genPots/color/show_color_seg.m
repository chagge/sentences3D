function show_color_seg(i_color)
root = '/Users/kongchen/sentences3D';
datadir = fullfile(root, 'NYU');
color_dataset_file = fullfile(datadir, 'descriptors', 'color_dataset.mat');

color_dataset = load(color_dataset_file);
colorlist = color_dataset.colorlist;

color = colorlist(i_color);
num_cases = color.num_appearance;

fprintf('%s\n', color.name);

for i = 1:num_cases
    figure;
    
    mask = uint8(roipoly(zeros(480,640), color.seg{i}(:, 1), color.seg{i}(:, 2)));
    mask = repmat(mask, [1,1,3]);
    im = imread(fullfile(datadir, 'images', sprintf('%04d.jpg', color.place(i))));
    im = im .* mask + uint8(ones(480, 640, 3) * 255 .* (mask == 0));
    imshow(im);
end