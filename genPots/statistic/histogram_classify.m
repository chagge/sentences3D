function [his_color, his_size, his_num, his_posi] = histogram_classify()
datadir = '/Users/kongchen/sentences3D/NYU';
histogram_adj_file = fullfile(datadir, 'histogram_adj.mat');
histogram_adj_class_file = fullfile(datadir, 'histogram_adj_class.mat');
his = load(histogram_adj_file);
his_adj = his.his_adj;
his_color = {};
his_size = {};
his_num = {};
his_posi = {};
for iadj = 1:size(his_adj,1);
    if his_adj{iadj,2} <= 3;
        continue;
    end
    class = input(sprintf('%s %d\n', his_adj{iadj,1}, his_adj{iadj,2}),'s');
    if strcmp(class,'stop')
        return;
    end
    if strcmp(class,'c')
        if isempty(his_color)
            his_color = his_adj(iadj,:);
        else
            his_color = [his_color; his_adj(iadj,:)];
        end
        fprintf('color + 1\n');
    end
    if strcmp(class,'s')
        if isempty(his_size)
            his_size = his_adj(iadj,:);
        else
            his_size = [his_size; his_adj(iadj,:)];
        end
        fprintf('size + 1\n');
    end
    if strcmp(class,'n')
        if isempty(his_num)
            his_num = his_adj(iadj,:);
        else
            his_num = [his_num; his_adj(iadj,:)];
        end
        fprintf('num + 1\n');
    end
    if strcmp(class,'p')
        if isempty(his_posi)
            his_posi = his_adj(iadj,:);
        else
            his_posi = [his_posi; his_adj(iadj,:)];
        end
        fprintf('posi + 1\n');
    end
end
save(histogram_adj_class_file, 'his_adj', 'his_color', 'his_size', 'his_num', 'his_posi');