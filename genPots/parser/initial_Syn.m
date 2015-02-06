datadir = '/share/data/sentences3d/NYU';


load('scene_classes_selected.mat');
classes = classes';
scenetypes = KC_GenerateSyns(classes(1:end-1));
load('classes_final.mat')
objects = KC_GenerateSyns(classes);
t = size(objects,2)+1;
objects(t).word = 'other';
objects(t).synonyms = ' other ';

