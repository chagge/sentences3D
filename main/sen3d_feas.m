function feas = sen3d_feas(cfg)
%SEN3D_FEAS Constructs a 3D indoor scene featureset
%
%   feas = SEN3D_FEAS(cfg);
%


%% main

% create feature set

feas = gcrf_feaset();

nc_s = numel(cfg.scene_classes);
nc_o = numel(cfg.object_classes);
if cfg.use_a
   nc_a = cfg.num_a_states;
else
   nc_a = 0;
end;

if cfg.use_bias
    nc_o = nc_o + 1;
    feas.add_feature('bias', nc_o);
end

if cfg.use_scene_score
    feas.add_feature('scene_score', nc_s);
end

if cfg.use_scene_text
    feas.add_feature('scene_text', nc_s);
end

if cfg.use_segment_score
    feas.add_feature('segment_score', nc_o);
end

if cfg.use_geometry_score
    feas.add_feature('geometry_score', nc_o);
end

if cfg.use_cpmc_score
    feas.add_feature('cpmc_score', nc_o);
end

if cfg.use_scene_object
    feas.add_feature('scene_object', [nc_s, nc_o]);
end

if cfg.use_object_next
    feas.add_feature('object_next', [nc_o, nc_o]);
end

% bias
if cfg.use_a
     feas.add_feature('bias_a', nc_a);
end

if cfg.use_best_cuboid
    feas.add_feature('best_cuboid', nc_a);
end

if cfg.use_size_cuboid
    feas.add_feature('size_cuboid', nc_a);
end

if cfg.use_text_cuboid
    feas.add_feature('text_cuboid', [nc_o, nc_a]);
    if cfg.use_diff_weight_it
        feas.add_feature('text_cuboid_it', [nc_o, nc_a]);
    end;
end

if cfg.use_variability_pot
    feas.add_feature('var_pot', [nc_a, nc_a]);
end;

