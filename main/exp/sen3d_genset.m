function sen3d_genset(objty)
%IN3D_GENSET Generates a scene struct dataset
%
%   R = IN3D_GENSET(threshold);
%

data_globals;
if ~exist(DATAFILES_OBJTY_DIR, 'dir')
    mkdir(DATAFILES_OBJTY_DIR);
end;

fcls = load(CLASS_FINAL);
spcls = load(CLASS_REDUCED);
sc_classes = load(SCENE_CLASSES);

scene_classes = sc_classes.classes;  %#ok<*NASGU>
object_classes = fcls.classes; 
spixel_classes = spcls.classes;
final_to_reduced = fcls.final_to_reduced;
reduced_to_final = fcls.reduced_to_final;

GTs = load(GTS_FILE);
GTs = GTs.GTs;

best_cuboid = load(BEST_CUBOID_POTS_FILE);

size_cuboid = load(SIZE_POTS_FILE);

co_stats = load(COSTAT_FILE);

is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end


info = in3d_baserecall();


n = 1449;
ss = cell(n, 1);

scene_labels = sc_classes.class_labels;

scene_pots = load(SCENEPOT_FILE);
scene_pots = scene_pots.scene_pots;

scene_text = load(SCENETEXT_FILE);
scene_text = scene_text.scene_text_pot;

all_seg_pots = load(CUB_SEGPOTS_FILE);
all_seg_pots = all_seg_pots.pots;

all_geo_pots = load(GEOPOTS_FILE);
all_geo_pots = all_geo_pots.pots;

As = load(AS_FILE);
Preps = As.Preps;
As = As.As;


cands = load(CANDIDATE_CUBOIDS_FILE);
cands = cands.cands;

cv_pots = load(CV_POTS_FILE);
cv_pots = cv_pots.pots;

for i = 1 : n      
    
    objs = load(fullfile(OBJ_DIR, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    segpots = all_seg_pots{i};
    geopots = all_geo_pots{i};
        
    s = [];
    s.scene_label = scene_labels(i);
    s.scene_pots = scene_pots(i, :);   
    s.scene_text = scene_text(i, :);
    
    nobjs = length(objs);
    assert(size(segpots, 1) == nobjs);
    
    [objs, use_inds] = select_obj(objs, fcls, is_final);
    nobjs = length(objs);
    
    os = cell(nobjs, 1);
    gt = GTs{i};
    
    if is_final
        assert(gt.nobjs == nobjs);
    end
    
    for j = 1 : nobjs
        o = [];
        oj = objs(j);
        
        if oj.label <= 0
            o.label = 0;
        else
            if is_final
                o.label = oj.label;
            else
                o.label = fcls.reduced_to_final(oj.label);
            end
        end
        
        
        if is_final || o.label > 0
            if is_final
                assert(oj.has_cube && ~oj.diff && ~oj.badannot);
            else
                if oj.diff || oj.badannot || ~oj.has_cube
                    continue;
                end
            end
            
            o.bndbox = oj.bndbox;
            o.cube = oj.cube;
            o.pixels = oj.pixels;
            
            o.seg_pots = segpots(use_inds(j), :);
            o.geo_pots = geopots(use_inds(j), :);
            if is_final
                o.cpmc_pots = oj.cpmc_score;
            else
                o.cpmc_pots = 0;
            end
            os{j} = o;  
            
            if is_final
                assert(gt.final_label(j) == o.label);
            end
        end
    end
    
    s.use_inds = use_inds;
    s.objects = vertcat(os{:});
    %s.segmentation = segs;
    
    s.a.as = As{i};
    s.a.best_cuboid_pots = best_cuboid.pots{i}; 
    s.a.size_cuboid_pots = size_cuboid.pots{i};
    s.a.num_a = size(best_cuboid.pots{i}, 1);
    s.a.num_states = size(best_cuboid.pots{i}, 2);
    s.a.label = best_cuboid.gts{i};
    s.a.list = best_cuboid.list{i};
    s.a.cand = cands{i};
    file = fullfile(GTS_DIR, sprintf('gt%04d.mat', i));
    if exist(file, 'file')
        textgt = load(file);
        textgt_allnoun = textgt.num_noun;
        textgt_allnoun_with_it = textgt.num_noun_with_it;
    else
        textgt_allnoun = 0;
        textgt_allnoun_with_it = 0;
    end
    s.a.all_nouns = textgt_allnoun;
    s.a.all_nouns_with_it = textgt_allnoun_with_it;
    s.a.cv_pots = cv_pots{i}; 
    s.i_sce = i;
    
    assert(length(s.use_inds) == length(s.objects));
      
    file = fullfile(DATAFILES_OBJTY_DIR, sprintf('ds%04d.mat', i));
 
    save(file, '-struct', 's');
    
    if mod(i, 20) == 0
        fprintf('processed %d ...\n', i);
    end
end

save(DATASET_FILE, 'scene_classes', 'object_classes', 'spixel_classes', ...
    'final_to_reduced', 'reduced_to_final', 'co_stats', 'info','GTs');
datafile = fullfile(DATA_OBJTY_DIR, sprintf('%s_data.mat', objty));

if exist(datafile, 'file')
    unix(sprintf('rm %s', datafile));
end;
sen3d_loaddata(objty);
