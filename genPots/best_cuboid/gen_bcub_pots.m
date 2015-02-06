function gen_bcub_pots(objty)
if nargin < 1
    objty = 'gt';
end;
data_globals;
disp('Data preparing...');

pots = cell(1449, 1);
gt = cell(1449, 1);
list = cell(1449, 1);
As = load(AS_FILE);
As = As.As;
segpots = load(CUB_SEGPOTS_FILE);
segpots = segpots.pots;
geoinfos = load(GEOINFO_FILE);
geoinfos = geoinfos.Gs;
geopots = load(GEOPOTS_FILE);
geopots = geopots.pots;
overlapdir = fullfile(OVERLAP_DIR, objty);
if ~exist(overlapdir, 'dir')
    mkdir(overlapdir);
end
fcls = load(CLASS_FINAL);
is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end

disp('Loading Models...');
models = load(CANDIDATE_MODELS_FILE);
best = models.best;

parti = models.norm;

for i_sce = 1:1449
    if mod(i_sce-1, 20)==0, fprintf('   doing %d/1449\n', i_sce); end;
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
       [overlaps, masks] = getOverlaps(objs, segs, obj_ids); %#ok<NASGU>
       save(overlapfile, 'overlaps', 'masks');
    end;
    
    for i_as = 1:num_as
        a = as(i_as);
        bias = 0;
        temp_pot = [];
        temp_gt = [];
        temp_list = [];
        for i_obj = 1:num_objs               
            obj = objs(i_obj);
            if obj.diff || obj.badannot || ~obj.has_cube
                bias = bias + 1;
                continue;
            end
            obj.segpot = segpot(i_obj, :);
            obj.geoinfo = geoinfo{i_obj};
            obj.geopot = geopot(i_obj, :);
            if isempty(a.obj_id)
                ovs = 0;
            else
                ovs = overlaps(i_obj, a.obj_id);
            end
            ov = max(ovs);
            [lb, f_vector] = get_feature_a_obj(a, obj, ov);
            f_vector = f_vector ./ parti;
            [~, ~, p] = svmpredict(1, f_vector, best.model, '-q');
            temp_pot(i_obj - bias) = p; %#ok<*AGROW>
            temp_gt(i_obj - bias) = lb;
            temp_list = ones(1,a.cardinality)*i_as;
        end
        pots{i_sce} = [pots{i_sce}; repmat(temp_pot, [a.cardinality, 1])];
        gt{i_sce} = [gt{i_sce}; repmat(temp_gt, [a.cardinality, 1])];
        list{i_sce} = [list{i_sce} ,temp_list]; 
    end    
end
save(BEST_CUBOID_O_POTS_FILE, 'pots', 'list', 'gt');

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