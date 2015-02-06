function his_size = histogram_size_bs()

data_globals;
k_size = numel(SIZE_LIST);
classes = load(CLASS_FINAL);
reduce = classes.reduced_to_final;
classes = classes.classes;
num_classes = numel(classes);
his_size = zeros(num_classes, 2);
labeled = get_labeled('INFO_DIR');
num_labeled = numel(labeled);
for i_s = 1:num_labeled
    if mod(i_s, 100) == 0
        fprintf('Processed %d / %d\n', i_s, num_labeled);
    end
    is = labeled(i_s);
    annotation = load(fullfile(INFO_DIR, sprintf('in%04d.mat',is)));
    classes = annotation.descriptions(1).class;
    num_class = numel(classes);
    for i_cls = 1:num_class
        class = classes(i_cls);
        id = str2num(class.id(2:end));
        id = reduce(id);
        if id
            num_inst = class.cardinality;
            for i_inst = 1:num_inst
                inst = class.instance(i_inst);
                adjs = inst.adj;
                pla = ismember(adjs, SIZE_LIST_BIG);
                if sum(pla) ~= 0;
                    his_size(id, 1) = his_size(id, 1) + 1;
                end
                pla = ismember(adjs, SIZE_LIST_SMALL);
                if sum(pla) ~= 0;
                    his_size(id, 2) = his_size(id, 2) + 1;
                end
            end
        end
    end
end
save(HIST_SIZE_FILE, 'his_size');