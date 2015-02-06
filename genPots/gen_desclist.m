function desclist = gen_desclist(labeled)
    
datadir = '/Users/kongchen/sentences3D/NYU';
final_dir = fullfile(datadir, 'descriptions_final');
dest_file = fullfile(datadir, 'descriptions_list');

if nargin < 1
    labeled = [1:800, 1341:1449];
end
desclist = {};

for i_image = labeled
    final_file = fullfile(final_dir, sprintf('%04d.mat', i_image));
    final = load(final_file);
    annotation = final.annotation;
    for i_des = 1:numel(annotation.descriptions);
        temp = sprintf('%04d_%d', i_image, i_des);
        desclist = [desclist; temp];
    end
end
save(dest_file, 'desclist');