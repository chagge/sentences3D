function gen_bcub_pots_a(objty)
if nargin < 2
    objty = 'gt';
end;
data_globals;
disp('Data preparing...');

pots = cell(1449, 1);
gt = cell(1449, 1);
list = cell(1449, 1);
As = load(AS_FILE);
As = As.As;

disp('Loading Models...');
models = load(CANDIDATE_MODELS_FILE);
best = models.best;

parti = models.norm;

for i_sce = 1:1449
    if mod(i_sce, 100) == 0
        fprintf('%d Processed.\n', i_sce);
    end
    segpots = load(SEGPOTS_FILE);
    segpots = segpots.pots;
    geoinfos = load(GEOINFO_FILE);
    geoinfos = geoinfos.Gs;
    geopots = load(GEOPOTS_FILE);
    geopots = geopots.pots;

    obj_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i_sce));
    obj_file_final = fullfile(DATASET_DIR, sprintf('ds%04d.mat', i_sce));
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));

    objs = load(obj_file_final);
    use_inds = objs.use_inds;
    objs = load(obj_file);
    objs = objs.objects;
    objs = objs(use_inds);
    num_objs = numel(objs);
    info = load(info_file);
    segpot = segpots{i_sce}(use_inds, :);
    geopot = geopots{i_sce}(use_inds, :);
    geoinfo = geoinfos{i_sce}(use_inds, :);
    
    as = As{i_sce};
    num_as = numel(as);

    if isempty(info.descriptions)
        continue;
    end
    for j = 1 : length(objs)
        mask = zeros(480, 640);
        mask(objs(j).pixels)=1;
        objs(j).mask = mask;
    end;

    i_a = 0;

    for i_as = 1:num_as
        aa = as(i_as);
        label = str2num(aa.class_id(2:end));
        num_inst = aa.cardinality;
        for i_inst = 1:num_inst
            i_a = i_a + 1;
            id = [aa.id, i_inst];
            adj = aa.adj;
            posi = aa.posi;
            a.name = aa.word;
            a.id = id;
            a.label = label;
            a.adj = adj;
            a.posi = posi;
            o_id = aa.obj_id;
            if id(3) <= numel(o_id)
                a.obj_id = o_id(id(3));
                if id(3) <= numel(aa.segs)
                    a.seg = aa.segs{id(3)};
                else
                    fprintf('in %d scene, object whose obj_id = %d does not have a seg.\n', i_sce, a.obj_id);
                    a.obj_id = 0;
                    a.seg = 0;
                end
            else
                a.obj_id = 0;
                a.seg = 0;
            end

            bias = 0;
            for i_obj = 1:num_objs               
                obj = objs(i_obj);
                if obj.diff || obj.badannot || ~obj.has_cube
                end
                obj.segpot = segpot(i_obj, :);
                obj.geoinfo = geoinfo{i_obj};
                obj.geopot = geopot(i_obj, :);
                [lb, f_vector] = get_feature_a_obj(a, obj);
                f_vector = f_vector ./ parti;
                [~, ~, p] = svmpredict(1, f_vector, best.model, '-q');
                pots{i_sce}(i_a, i_obj - bias) = p;
                gt{i_sce}(i_a, i_obj - bias) = lb;
                list{i_sce}(i_a) = i_as; 
            end
        end 
    end    
end
save(BEST_CUBOID_O_POTS_FILE, 'pots', 'list', 'gt');