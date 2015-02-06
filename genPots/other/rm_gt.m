function rm_gt()
data_globals;
labeled = get_labeled('GTS_DIR');
for i_lb = 1:numel(labeled)
    i_sce = labeled(i_lb);
    file = fullfile(GTS_DIR, sprintf('gt%04d.mat', i_sce));
    gt = load(file);
    if ~isfield(gt, 'gt')
        continue;
    end
    gt = gt.gt;
    save(file, '-struct', 'gt');
end