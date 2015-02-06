function [samples, loss] = sen3d_scenesamples(cfg, scenes)
%SEN3D_SCENESAMPLES Construct a GCRF sample set from a set of scenes
%
%   samples = SEN3D_SCENESAMPLES(cfg, scenes);
%
%       creates a sample set, a cell array of gcrf_sample object. 
%
%   [samples, loss] = SEN3D_SCENESAMPLES(cfg, scenes);
%
%       additionally creates and returns a loss object (of class
%       gcrf_loss).
%

%% main

Ks = numel(cfg.scene_classes);
Ko = numel(cfg.object_classes);
if cfg.use_a
   Ka = cfg.num_a_states;
else
   Ka = 0;
end;
is_real = cfg.is_real;

n = numel(scenes);

use_bias = cfg.use_bias;
use_a = cfg.use_a;
use_a_pairwise_loss = cfg.use_a_pairwise_loss;

% create sample set

samples = cell(1, n);
for i = 1 : n
    sc = scenes(i);
    nobjs = numel(sc.objects);
    if use_a
       na = sc.a.num_a;
    else 
       na = 0;
    end;
    
    spl = gcrf_sample();
    spl.add_local('scene', Ks);
    if nobjs > 0
        if use_bias
            spl.add_locals('object', nobjs, Ko+1);
        else
            spl.add_locals('object', nobjs, Ko);
        end
    end
    if use_a
        spl.add_locals('a', na, Ka);
    end
    
    samples{i} = spl;
end

% create loss

if nargout >= 2    
    loss = gcrf_loss(samples);
    for i = 1 : n
        sc = scenes(i);        
        if is_real
           loss.set_gt(i, 1, sc.scene_label, 1); 
        else
           loss.set_gt(i, 1, sc.scene_label, 0.5);
        end;
        
        nobjs = numel(sc.objects);
        for j = 1 : nobjs
            o = sc.objects(j);
            assert(o.label <= Ko);
            if o.label > 0            
                if use_bias
                    o_loss = ones(1, Ko + 1);
                    o_loss(o.label) = 0;
                    o_loss(end) = 30;
                    loss.set_gt(i, 1+j, o_loss, 5);
                else
                    loss.set_gt(i, 1+j, o.label, 1);    
                end;
            elseif use_bias && o.label == 0
                loss.set_gt(i, 1+j, Ko+1, 1);
            end
        end
        if use_a
            na = sc.a.num_a;
            num_a = zeros(1, na);
            for j = 1 : na
                id = sc.a.list(j);
                num_a(j) = numel(find(sc.a.list == id));
            end;
            for j = 1 : na
                class = sc.a.as(sc.a.list(j)).class;
                a_loss = 1 - sc.a.label(j, :);
                if ~is_real
                    if ~strcmp(class, 'pronoun')
                       a_loss(1) = 6*a_loss(1);
                       a_loss = a_loss * 15;
                    else
                       a_loss(1) = 6*a_loss(1);
                       a_loss = a_loss * 15;
                    end;
                    a_loss(nobjs+2:end) = 120;
                else
                   if ~strcmp(class, 'pronoun')
                       a_loss(1) = 6*a_loss(1);
                       a_loss = a_loss * 20;
                    else
                       a_loss(1) = 6*a_loss(1);
                       a_loss = a_loss * 20;
                    end;
                    a_loss(nobjs+2:end) = 200;

                end;
                if max(sc.a.best_cuboid_pots(j, nobjs+2:end)) > -100
                    fprintf('error with a!\n');
                end;
                loss.set_gt(i,1+nobjs+j, a_loss);
            end

            if use_a_pairwise_loss
               list = sc.a.list;
               sz = size(sc.a.label, 2);
               for j = 1 : na
                   id = list(j);
                   ind_id = find(list == id);
                   if length(ind_id) == 1   % we don't have plural
                       continue;
                   end;
                   ind1 = find(ind_id > j);
                   if isempty(ind1)
                       continue;
                   end;
                   ind = ind_id(ind1);

                   for k = 1 : length(ind)
                       j2 = ind(k);
                       loss_aa = zeros(sz, sz);
                       if ~is_real
                           for l = 2 : sz
                               % encourage labels to be different
                               loss_aa(l,l) = 10;   
                           end;
                       else
                           for l = 2 : sz
                               % encourage labels to be different
                               loss_aa(l,l) = 50;   
                           end;
                       end;
                       loss_aa(nobjs+2 : end, :) = 0;
                       loss_aa(:, nobjs+2:end) = 0;
                       loss.set_gt_pairwise(i, [1+nobjs+j,1+nobjs+j2], loss_aa, 1)
                   end;
               end;
            end;
        end
    end        
end


