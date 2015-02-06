function human_acc()
data_globals;
sce_cls = load(SCENE_CLASSES);
dataset = 1:1449;
ndata = numel(dataset);

nsce = numel(sce_cls.classes);
scene_occ = zeros(nsce-1, 1);
% sce_cls.classes = strrep(sce_cls.classes, '_', ' ');
predict = zeros(ndata, 1);
available = [];

for idata = dataset
    scene_occ = zeros(nsce-1, 1);
    gtfile = fullfile(GTS_DIR, sprintf('gt%04d.mat',idata));
    if ~exist(gtfile, 'file')
        continue;
    end
    if mod(idata, 100) == 0
        fprintf('doing %d\n', idata);
    end
    annot = load(gtfile);
    classes = annot.class;
    num_classes = numel(classes);
    for i_class = 1:num_classes
        class = classes(i_class);
        [ia, ib] = ismember(class.name, sce_cls.classes(1:end-1));
        if ia
            scene_occ(ib) = 1;
        end
    end
    gt = sce_cls.class_labels(idata);
    if gt == 13
        continue;
    end
    if scene_occ(gt) == 1
        predict(idata) = gt;
        available = [available; idata]; %#ok<*AGROW>
    else
        sceid = find(scene_occ == 1);
        if ~isempty(sceid)
            predict(idata) = sceid(1);
            available = [available; idata];
        end
    end
end
C = confusionMatrix(sce_cls.class_labels(available), predict(available));
fprintf('accuracy: %0.4f\n', mean(diag(C)));
confusion_matrix(C/100, sce_cls.classes(1:end-1));

save(HUMAN_FILE, 'C', 'available', 'predict');
