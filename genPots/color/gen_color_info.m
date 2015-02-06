function colorlist = gen_color_info(store, overwrite)

if nargin < 1
    store = 0;
end;
if nargin < 2
    overwrite = 0;
end;

nyu_globals;

if store & overwrite == 0 & exist(COLORLIST_FILE, 'file')
    load(COLORLIST_FILE);
    return;
end;


final_dir = COLORGT_DIR;

datasetinfo = get_dataset_info('all');
dataset = datasetinfo.all;

colorlist = [];
colnames = [];

for i_sce = 1:numel(dataset)
    final_file = fullfile(final_dir, sprintf('%04d.mat', dataset(i_sce)));   
    final = load(final_file);
    annotation = final.annotation;
    seg = annotation.seg;    
    color = annotation.color;
    names = arrayfun(@(x)x.name, color, 'UniformOutput', 0);
    diff = cell2mat(arrayfun(@(x)x.difficult, color, 'UniformOutput', 0));
    %ind = strmatch('notlabeled', names, 'exact');
    %ind = setdiff([1:length(seg)]', ind);
    %ind = ind(find(diff(ind) == 0)); 
    ind = find(diff == 0);
    
    for j = 1 : length(ind)
        name = names{ind(j)};
        clcls = strmatch(name, colnames, 'exact');
        if isempty(clcls)
            clcls = length(colorlist) + 1;
            colorlist(clcls).place = [];
            colorlist(clcls).object = [];
            colorlist(clcls).seg = [];
            colorlist(clcls).num_appearance = 0;
            colorlist(clcls).name = name;
            colorlist(clcls).brightness = [];
            colnames = [colnames; {name}];
        end;
        colorlist(clcls).place = [colorlist(clcls).place; dataset(i_sce)];
        colorlist(clcls).object = [colorlist(clcls).object; annotation.class(ind(j))]; %#ok<*AGROW>

        colorlist(clcls).seg = [colorlist(clcls).seg; seg(ind(j))];
        colorlist(clcls).brightness = [colorlist(clcls).brightness; {color(ind(j)).brightness}];

        colorlist(clcls).num_appearance = colorlist(clcls).num_appearance + 1;
    end;
end;

if store
    save(COLORLIST_FILE, 'colorlist')
    fprintf('output stored to: %s\n', COLORLIST_FILE);
end;



