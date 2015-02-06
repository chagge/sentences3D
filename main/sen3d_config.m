function cfg = sen3d_config(filename, objty)
%SEN3D_CONFIG Reads a config file 
%
%   cfg = SEN3D_CONFIG(filename, objty)
%

%% main
data_globals;
[~, cfg_title] = fileparts(filename);

text = textread(filename, '%s', 'delimiter', '\n'); %#ok<REMFF1>

cfg = [];

% options with default 

cfg.use_bias = 0;
cfg.use_segment_score = 0;
cfg.use_geometry_score = 0;
cfg.use_cpmc_score = 0;
cfg.is_real = 0;

cfg.use_scene_object = 0;
cfg.use_object_next = 0;

cfg.use_scene_text = 0;
cfg.use_best_cuboid = 0;
cfg.use_size_cuboid = 0;
cfg.use_text_cuboid = 0;
cfg.use_variability_pot = 0;
cfg.use_a_pairwise_loss = 0;
cfg.use_diff_weight_it = 0;
cfg.use_it = 0;

for i = 1 : length(text)
    stmt = strtrim(text{i});
    if isempty(stmt) || stmt(1) == '#'
        continue;
    end
    
    [name, val] = parse_stmt(stmt);
        
    switch lower(name)
        case { 'use_bias', ...
                'use_scene_score', ...
                'use_segment_score', ...
                'use_geometry_score', ...
                'use_cpmc_score', ...
                'use_scene_object', ...
                'use_object_next', ...
                'learning_iters',...
                'is_real',...
                'use_scene_text',...
                'use_best_cuboid',...
                'use_size_cuboid',...
                'use_text_cuboid',...
                'use_a_pairwise_loss',...
                'use_it',...
                'use_variability_pot',...
                'use_diff_weight_it'}
           
           cfg.(name) = str2double(val);
           
        otherwise
            error('Unknown option %s at line %d\n', name, i);
    end   
end
cfg.data_dir = DATADIR;
cfg.output_dir = fullfile(RESULTDIR, cfg_title, objty);
cfg.split_file = SPLIT_FILE;
   
% check variable

cfg.use_a = cfg.use_best_cuboid + cfg.use_text_cuboid;


% check directory 

if ~exist(cfg.data_dir, 'dir')
    error('The %s is missing.', cfg.data_dir);
end
if ~exist(cfg.split_file, 'file')
    error('The %s is missing.', cfg.split_file);
end

% set default values

if ~isfield(cfg, 'learning_iters')
    cfg.learning_iters = 20;
end

if ~isfield(cfg, 'learning_rgap')
    cfg.learning_rgap = 1.0e-4;
end

% load classes and stats

cfg.split = load(cfg.split_file);

cfg.data = sen3d_loaddata(objty); 
cfg.scene_classes = cfg.data.scene_classes;
cfg.object_classes = cfg.data.object_classes;
if cfg.use_a
   cfg.num_a_states = cfg.data.S(1).a.num_states;
%    data = load(fullfile(AS_STATS_FILE));
end;

Ks = length(cfg.scene_classes);
Ko = length(cfg.object_classes);

co_stats = cfg.data.co_stats;

assert(isequal(size(co_stats.so), [Ks Ko]));
assert(isequal(size(co_stats.oo), [Ko Ko]));

% hacky

cfg.scene_object_pots = co_stats.so ./ repmat(sum(co_stats.so, 2), [1, size(co_stats.so, 2)]);

cfg.object_object_pots = 2 * (co_stats.oo > 0) - 1;


cfg.object_next_pots = co_stats.oo_next ./ repmat(sum(co_stats.oo_next, 2), [1, size(co_stats.oo_next, 2)]);

if cfg.use_a
   cfg.a_cuboid_pots = cfg.data.stats;
end;


function [name, val] = parse_stmt(s)

ieq = strfind(s, '=');
assert(isscalar(ieq));

name = strtrim(s(1:ieq-1));
val = strtrim(s(ieq+1:end));


