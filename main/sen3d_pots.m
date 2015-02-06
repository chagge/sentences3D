function pots = sen3d_pots(cfg, feas, scenes, samples)
%SEN3D_POTS Create a potential set over input scenes
%
%   pots = SEN3D_POTS(cfg, feas, scenes, samples);
%
%       Creates a potential set on the input scenes, based on the given
%       feature setting.
%
%       Inputs:
%       - cfg:      The model configuration (see config.txt)
%       - feas:     The feature set (an instance of gcrf_feaset)
%       - scenes:   The array of scenes (see scene_structs.txt)
%       - samples:  A sample set constructed on the scenes
%                   (use in3d_scenesamples)
%
%       Outputs:
%       - pots:     The created potential set (instance of gcrf_potset).
%

%% check model setting
data_globals;

use_bias = cfg.use_bias;

use_scene_score = cfg.use_scene_score;
use_segment_score = cfg.use_segment_score;
use_geometry_score = cfg.use_geometry_score;
use_cpmc_score = cfg.use_cpmc_score;

use_scene_object = cfg.use_scene_object;
use_object_next = cfg.use_object_next;
is_real = cfg.is_real;

so_pot = cfg.scene_object_pots;
oo_next_pot = cfg.object_next_pots;
if cfg.use_a
   a_cuboid_pot = cfg.a_cuboid_pots;
end;

use_scene_text = cfg.use_scene_text;
use_best_cuboid = cfg.use_best_cuboid;
use_size_cuboid = cfg.use_size_cuboid;
use_text_cuboid = cfg.use_text_cuboid;
use_variability_pot = cfg.use_variability_pot;
use_diff_weight_it = cfg.use_diff_weight_it;
use_it = cfg.use_it;

use_a = cfg.use_a;

if isfield(cfg, 'object_top_pots')
    oo_top_pot = cfg.object_top_pots;
end

Ks = length(cfg.scene_classes);
Ko = length(cfg.object_classes);
if cfg.use_a
   Ka = cfg.num_a_states;
else
   Ka = 0;
end;

if use_bias
    so_pot = [so_pot zeros(Ks, 1)];
    
    oo_next_pot = [oo_next_pot zeros(Ko, 1); zeros(1, Ko) 0];
    
    bias_pot = [zeros(1, Ko), -1];
end



%% potential set construction

pots = gcrf_potset(feas, samples);
n = numel(samples);

for i = 1 : n
    s = scenes(i);
    nobjs = numel(s.objects);
    
    if use_bias        
        for j = 1 : nobjs
            pots.set_pot('bias', i, 1+j, bias_pot);
        end
    end

    if use_scene_score
        if is_real
           pots.set_pot('scene_score', i, 1, 10*1./(1+exp(-1*s.scene_pots)));
        else
           pots.set_pot('scene_score', i, 1,10*1./(1+exp(-1*s.scene_pots)));
        end;
    end
    
    if use_scene_text
        %pots.set_pot('scene_text', i, 1, 20*1./(1+exp(-1*s.scene_text)));
        pots.set_pot('scene_text', i, 1, 2000*1./(1+exp(-1*s.scene_text)));
    end
    
    if use_segment_score
        for j = 1 : nobjs
            if use_bias
                p = [s.objects(j).seg_pots(1:Ko), 0];%+1);
            else
                p = s.objects(j).seg_pots(1:Ko);
            end
            if is_real
               p = s.objects(j).seg_pots(1:Ko+1);
               %pots.set_pot('segment_score', i, 1+j, p);
               pots.set_pot('segment_score', i, 1+j, 10*1./(1+exp(-1*p)));
            else
               pots.set_pot('segment_score', i, 1+j, 10*1./(1+exp(-1*p)));
            end
        end
    end
    
    if use_geometry_score
        for j = 1 : nobjs
            p = make_upot(s.objects(j).geo_pots(1:Ko), use_bias);
            pots.set_pot('geometry_score', i, 1+j, p);
            %pots.set_pot('geometry_score', i, 1+j, 1./(1+exp(-1*p)));
        end
    end
        
    if use_cpmc_score
        for j = 1 : nobjs
            if use_bias
                p = 2*1./(1+exp(-1*s.objects(j).cpmc_pots(1:Ko+1)));
            else
                p = s.objects(j).cpmc_pots(1:Ko);
            end
            pots.set_pot('cpmc_score', i, 1+j, p); 
        end
    end

    
    if use_scene_object
        if ~is_real
           so_pot(so_pot==0) = -1;
           pot = so_pot;
        else
           so_pot(so_pot==0) = -1;
           pot = so_pot;
        end;
        for j = 1 : nobjs
            pots.set_pot('scene_object', i, [1, 1+j], pot);
        end
    end
    
    if use_object_next
        if ~is_real
           oo_next_pot(oo_next_pot==0)=-10;
        else
           oo_next_pot(oo_next_pot==0)=-1;
           %oo_next_pot(:, end) = 0;
           %oo_next_pot(end, :) = 0;
        end;
        for j1 = 1 : nobjs
            for j2 = j1+1 : nobjs                
                if in3d_is_next(s.objects(j1), s.objects(j2))
                    pots.set_pot('object_next', i, [1+j1 1+j2], oo_next_pot);
                end
            end
        end
    end
    
    % bias
    if use_a    
        na = size(s.a.best_cuboid_pots, 1);
         for j = 1 : na;
             p = zeros(1, Ka);
             p(1) = 0.1;
             pots.set_pot('bias_a', i, 1+nobjs+j, p);
         end
    end
    
    if use_best_cuboid
        for j = 1 : na;
            list = s.a.list;
            p = s.a.best_cuboid_pots(j, :);
            if nobjs > 0
               p(1) = -1;%min(p(2:1+nobjs));
            end;
            class = s.a.as(list(j)).class;
            if ~use_it && strcmp(class, 'pronoun')
                p = zeros(size(p));
            end;
            pot_name = 'best_cuboid';
            pots.set_pot(pot_name, i, 1+nobjs+j, p);
        end
    end
    
    if use_size_cuboid
        for j = 1 : na;
            p = s.a.size_cuboid_pots(j, :);
            if nobjs > 0
               p(1) = 0;%min(p(2:1+nobjs));
            end;
            class = s.a.as(list(j)).class;
            if ~use_it && strcmp(class, 'pronoun')
                p = zeros(size(p));
            end;
            pots.set_pot('size_cuboid', i, 1+nobjs+j, p);
        end
    end
    
    if use_text_cuboid
        for j1 = 1:na
            cands = s.a.cand;
            cand = cands(j1,:);
            a_states = find(cand ~= 0);
            cand_list = cand(a_states);
            list = s.a.list;
            if isempty(list)
                continue;
            end
            class = s.a.as(list(j1)).class;
            pot_name = 'text_cuboid';
            if use_diff_weight_it && strcmp(class, 'pronoun')
                pot_name = 'text_cuboid_it';
            end;
            pred_class_id = str2num(s.a.as(list(j1)).pred_class_id(2:end));
            cls_id = pred_class_id;
            if strcmp(class, 'pronoun') && use_it == 0
               continue;
            end;
            if cls_id ==0
                continue; 
            end;
            
            if ~use_bias
               temp = a_cuboid_pot(cls_id, 1:Ko);
            else
               temp = a_cuboid_pot(cls_id, 1:Ko);
            end;
            temp = temp / (sum(temp) + eps);
            temp(temp==0) = -1;
            for j2f = 1:numel(cand_list)
                j2 = cand_list(j2f);
                a_state = a_states(j2f);
                p = zeros(Ka, Ko + use_bias);
                p(a_state,1:Ko) = temp;
                p = p';
                pots.set_pot(pot_name, i, [1+j2, 1+nobjs+j1], p);
            end
        end
    end

    if use_variability_pot 
        list = s.a.list;
        for j = 1 : na
            id = list(j);
            ind = find(list == id);
            k = find(ind > j);
            if isempty(k)
                continue
            end;
            ind = ind(k);
            for k = 1 : length(ind)
                j2 = ind(k);
                p = zeros(size(s.a.label,2), size(s.a.label, 2));
                for l = 2 : size(p, 2)
                    p(l,l) = -10;
                end;
               pots.set_pot('var_pot', i, [1+nobjs+j, 1+nobjs+j2], p); 
            end;
        end;
    end
    
end
fprintf('\n');



function p = make_upot(p, use_bias)

if use_bias
    p = [p 0];
end
    


