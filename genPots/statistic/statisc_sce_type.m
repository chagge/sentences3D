datadir = '/Users/kongchen/sentences3D/NYU';
sce_cls_file = fullfile(datadir, 'scene_classes.mat');
history_file = fullfile(datadir, 'history.mat');

history = load(history_file);
labeled = history.labeled;
sce_cls = load(sce_cls_file);
nsce = numel(sce_cls.classes);
y = zeros(nsce,1);

for isce = 1:nsce
    num = numel(intersect(labeled,find(sce_cls.class_labels == isce)));
    y(isce) = num;
end

bar(y);
title('# of images for each types');
xlabel('Classes');
ylabel('Number');
set(gca,'xticklabel',sce_cls.classes);