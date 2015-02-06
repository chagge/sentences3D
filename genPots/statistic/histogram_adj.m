function his_adj = histogram_adj()

data_globals;

his_adj = {};
s_num = 800;
for is = 1:s_num;
    annotation = load(fullfile(INFO_DIR, sprintf('in%04d.mat',is)));
    for idep = 1:numel(annotation.descriptions)
        for isent = 1:numel(annotation.descriptions(idep).tag)
            tag = annotation.descriptions(idep).tag{isent};
            id_adj = find(strcmp(tag(:,2),'JJ'));
            for iadj = 1:numel(id_adj)
                adj = tag{id_adj(iadj),1};
                if isempty(his_adj)
                    his_adj = {adj,1};
                    continue;
                end
                id_his = find(strcmp(his_adj(:,1),adj));
                if isempty(id_his)
                    his_adj = [his_adj;{adj,1}];
                else
                    his_adj{id_his,2} = his_adj{id_his,2} + 1;
                end
            end
        end
    end
end
save(HIST_ADJ_FILE, 'his_adj');