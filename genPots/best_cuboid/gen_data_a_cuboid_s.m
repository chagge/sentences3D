function [label_vector, instance_matrix] = gen_data_a_cuboid_s(set, objty)
if nargin < 2
    objty = 'gt';
end;
label_vector = [];
instance_matrix = [];
data_globals;
dataclasses = load(CLASS_FINAL);
segpots = load(SEGPOTS_FILE);
segpots = segpots.pots;
geoinfos = load(GEOINFO_FILE);
geoinfos = geoinfos.Gs;
geopots = load(GEOPOTS_FILE);
geopots = geopots.pots;
overlapdir = fullfile(OVERLAP_DIR, objty);
if ~exist(overlapdir, 'dir'), mkdir(overlapdir); end;

for i_set = 1:numel(set)
    if mod(i_set-1, 20)==0, fprintf('   doing %d/%d\n', i_set, numel(set)); end;
    i_sce = set(i_set);
    obj_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i_sce));
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    
    objs = load(obj_file);
    objs = objs.objects;
    num_objs = numel(objs);
    info = load(info_file);
    segpot = segpots{i_sce};
    geopot = geopots{i_sce};
    geoinfo = geoinfos{i_sce};
    
    if isempty(info.descriptions)
        continue;
    end
    for j = 1 : length(objs)
        mask = zeros(480, 640);
        mask(objs(j).pixels)=1;
        objs(j).mask = mask;
    end;
    classes = info.descriptions(1).class;  
    preps = info.descriptions(1).prep;
    num_cls = numel(classes);
    num_prep = size(preps,1);
    sentences = info.descriptions(1).sentences;
    segs = info.seg;
    obj_ids = info.descriptions(1).obj_id;
    overlapfile = fullfile(overlapdir, sprintf('%04d.mat', i_sce));
    if exist([overlapfile ''], 'file')
        load(overlapfile);
    else
       [overlaps, masks] = getOverlaps(objs, segs, obj_ids);
       save(overlapfile, 'overlaps', 'masks');
    end;
    
    
    for i_cls = 1:num_cls
        class = classes(i_cls);
        label = str2num(class.id(2:end));
        label = dataclasses.reduced_to_final(label);
        if label == 0
            continue;
        end
        num_inst = class.cardinality;
        instances = class.instance;
        for i_inst = 1:num_inst
            instance = instances(i_inst);
            id = instance.id;
            adj = instance.adj;
            id_word = instance.id_word;
            posi = {};
            for i_prep = 1:num_prep
                prep = preps(i_prep, :);
                if isequal(id, prep{1})
                    temp = [prep{2}, ' ', sentences{prep{3}(1)}{prep{3}(2)}];
                    posi = [posi, temp]; %#ok<AGROW>
                end
            end
            a.name = sentences{id(1)}{id(2)};
            a.id = id;
            a.label = label;
            a.adj = adj;
            a.posi = posi;
            if isempty(obj_ids{id_word})
                o_id = [];
            else
                o_id = str2num(obj_ids{id_word});
            end
            
            if id(3) <= numel(o_id)
                a.obj_id = o_id(id(3));
                if a.obj_id <= numel(segs)
                    a.seg = segs{a.obj_id};
                    a.mask = masks{a.obj_id};
                else
                    fprintf('in %d scene, object whose obj_id = %d does not have a seg.\n', i_sce, a.obj_id);
                    a.obj_id = 0;
                    a.seg = 0;
                end
            else
                a.obj_id = 0;
                a.seg = 0;
            end
            
            for i_obj = 1:num_objs               
                obj = objs(i_obj);
                if obj.diff || obj.badannot || ~obj.has_cube
                    continue;
                end
                obj.segpot = segpot(i_obj, :);
                obj.geoinfo = geoinfo{i_obj};
                obj.geopot = geopot(i_obj, :);
                if a.obj_id~=0
                    ov = overlaps(i_obj, a.obj_id);
                else
                    ov = 0;
                end;
                [lb, f_vector] = get_feature_a_obj(a, obj, ov);
                upper = 0.5;
                lower = 0.3;
                if lb >= upper
                    label = 1;
                end
                if lb < lower
                    label = -1;
                end
                if lb > lower && lb < upper
                    label = 0;
                    %continue;
                end
                if length(o_id) > 1
                    m = max(overlaps(i_obj, o_id));
                    if  m >= 0.5
                        label = 0;
                    end;
                end;
                label_vector = [label_vector; label]; %#ok<AGROW>
                instance_matrix = [instance_matrix; f_vector]; %#ok<AGROW>
            end
        end
    end   
end
if size(label_vector,1) ~= size(instance_matrix, 1)
    error('sizes of labels and instances are inconsistent...');
end


function [overlaps, masks] = getOverlaps(objs, segs, obj_ids)

ids = [];
for i = 1 : length(obj_ids)
    if ~isempty(obj_ids{i})
        s = str2num(obj_ids{i})';
        if size(s, 2)> size(s, 1), s = s'; end;
        ids = [ids; s];
    end;
end;

ids = unique(ids);
temp = zeros(480, 640);
masks = cell(length(segs), 1);
for i = 1 : length(ids)
    masks{ids(i)} = roipoly(temp, segs{ids(i)}(:, 1), segs{ids(i)}(:, 2));
end;

overlaps = zeros(length(objs), length(segs));
for i = 1 : length(objs)
    for j = 1 : length(ids)
        mask = objs(i).mask + masks{ids(j)};
        overlaps(i, ids(j)) = numel(find(mask > 1)) / numel(find(mask >= 1));
    end;
end;

ind = find(isnan(overlaps) | isinf(overlaps));
overlaps(ind) = 1;