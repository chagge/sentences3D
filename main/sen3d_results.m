function r = sen3d_results(cfg, scenes, preds)
%SEN3D_RESULTS Translates CRF predictions into scene parsing results
%
%   r = SEN3D_RESULTS(cfg, scenes, preds);
%

ns = length(preds);
r = cell(ns, 1);
use_a = cfg.use_a;

for i = 1 : ns
    p = preds(i);
    s = scenes(i);
    
    nobjs = numel(s.objects);
    
    if use_a
       na = s.a.num_a;
    else 
       na = 0;
    end;
    if use_a
        assert(numel(p.node) == nobjs + na + 1);
    else
        assert(numel(p.node) == nobjs + 1);
    end
    
    ri = [];
    % get scene prediction.
    [~, ri.scene_label] = max(p.node{1});
    
    % get object prediction.
    ri.object_labels = zeros(1, nobjs);
    for j = 1 : nobjs
        [~, ri.object_labels(j)] = max(p.node{j+1});
    end
    
    % get pronoun prediction.
    if use_a
        for j = 1 : na
            [~, ri.a_labels(j)] = max(p.node{j+nobjs+1});
        end
        if na == 0
            ri.a_labels = [];
        end
    end
    
    r{i} = ri;
end

r = vertcat(r{:});