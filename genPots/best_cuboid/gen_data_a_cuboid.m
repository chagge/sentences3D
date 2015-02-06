function [label_vector, instance_matrix] = gen_data_a_cuboid(set, objty)
if nargin < 2
    objty = 'gt';
end;
threshold = '0.20'; %#ok<NASGU>
label_vector = [];
instance_matrix = [];
data_globals;
segpots = load(CUB_SEGPOTS_FILE);
segpots = segpots.pots;
geoinfos = load(GEOINFO_FILE);
geoinfos = geoinfos.Gs;
geopots = load(GEOPOTS_FILE);
geopots = geopots.pots;
overlapdir = fullfile(OVERLAP_DIR, objty);
if ~exist(overlapdir, 'dir'), mkdir(overlapdir); end;
fcls = load(CLASS_FINAL);

As = load(AS_FILE);
As = As.As;

is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end

for i_set = 1:numel(set)
    if mod(i_set-1, 20)==0, fprintf('   doing %d/%d\n', i_set, numel(set)); end;
    i_sce = set(i_set);
    obj_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i_sce));
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    
    objs = load(obj_file);
    objs = objs.objects;
    [objs, use_inds] = select_obj(objs, fcls, is_final);
    num_objs = numel(objs);
    info = load(info_file);
    segpot = segpots{i_sce}(use_inds, :);
    geopot = geopots{i_sce}(use_inds, :);
    geoinfo = geoinfos{i_sce}(use_inds, :);
    
    if isempty(info.descriptions)
        continue;
    end
    for j = 1 : length(objs)
        mask = zeros(480, 640);
        mask(objs(j).pixels)=1;
        objs(j).mask = mask;
    end;  
    as = As{i_sce};
    num_as = numel(as);
    segs = info.seg;
    obj_ids = info.descriptions(1).obj_id;
    overlapfile = fullfile(overlapdir, sprintf('%04d.mat', i_sce));
    if exist([overlapfile '1'], 'file')
        load(overlapfile);
    else
       [overlaps, ~] = getOverlaps(objs, segs, obj_ids);
       save(overlapfile, 'overlaps', 'masks');
    end;
    
    for i_as = 1:num_as
        a = as(i_as);
        if strmatch(a.class, 'pronoun')
            ispronoun = 1;
        else
            ispronoun = 0;
        end;
        for i_obj = 1:num_objs               
            obj = objs(i_obj);
            if obj.diff || obj.badannot || ~obj.has_cube
                continue;
            end
            obj.segpot = segpot(i_obj, :);
            obj.geoinfo = geoinfo{i_obj};
            obj.geopot = geopot(i_obj, :);
            if isempty(a.obj_id)
                ov = 0;
            else
                ov = max(overlaps(i_obj, a.obj_id));
            end
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
            %label = repmat(label, [a.cardinality, 1]);
            %f_vector = repmat(f_vector, [a.cardinality, 1]);
            label_vector = [label_vector; [label, ispronoun]]; 
            instance_matrix = [instance_matrix; f_vector];
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
        ids = [ids; s]; %#ok<AGROW>
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
overlaps(ind) = 1; %#ok<FNDSB>