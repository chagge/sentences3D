function R = sen3d_evalresults(cfg, scenes, results, base_recall, c_base_recalls)
%SEN3D_EVALRESULTS Evaluate performances on a set of results
%
%   R = SEN3D_EVALRESULTS(cfg, scenes, results, base_recall, c_base_recalls);
%
%   Inputs:
%   - cfg:      The framework configuration
%   - scenes:   The set of scene structs
%   - results:  The prediction results (made by in3d_results)
%
%   Outputs:
%   - R:        A struct with following fields:
%               - scene_accuracy:   scene classification accuracy
%               - object_accuracy:  object classification accuracy
%               - scene_confusion:  scene classification confusion mat
%               - object_confusion: object classification confusion mat
%

%% main

if nargin < 4
    base_recall = 1;
end

assert(numel(scenes) == numel(results));
ns = numel(scenes);

Ks = numel(cfg.scene_classes);
Ko = numel(cfg.object_classes);

% build confusion matrices

use_bias = cfg.use_bias;
use_a = cfg.use_a;
is_real = cfg.is_real;

Cs = zeros(Ks, Ks);     % scene confusion

if use_bias
    Co = zeros(Ko+1, Ko+1);
else    
    Co = zeros(Ko, Ko);     % object confusion
end

right_a = 0;
al_nouns = 0;
al_preds = 0;
right_a_with_it = 0;
al_nouns_with_it = 0;
al_preds_with_it = 0;

for i = 1 : ns
    
    s = scenes(i);
    r = results(i);
    
    sl0 = s.scene_label;
    slr = r.scene_label;
    
    Cs(sl0, slr) = Cs(sl0, slr) + 1;
        
    nobjs = numel(s.objects);
    assert(numel(r.object_labels) == nobjs);
    
    for j = 1 : nobjs
        ol0 = s.objects(j).label;
        olr = r.object_labels(j);
        
        if use_bias
            if ol0 == 0
                ol0 = Ko + 1;
            end
            if olr == 0
                olr = Ko + 1;
            end
        end
        
        Co(ol0, olr) = Co(ol0, olr) + 1;
    end  
    
    if use_a
        lbs = r.a_labels;
        
        list = s.a.list;
        num_n = max(list);
        if isempty(num_n)
            num_n = 0;
        end
        for i_n = 1:num_n
            id = find(list == i_n);
            is_pronoun = strcmp(s.a.as(i_n).class, 'pronoun');
            if ~is_pronoun
                al_preds = al_preds + 1;
            end
            al_preds_with_it = al_preds_with_it + 1;
                
            labels = lbs(id);
            mask = zeros(480, 640);
            for i_l = 1:numel(labels)
                lb = labels(i_l);
                lb = s.a.cand(id(i_l), lb);
                if lb == 0
                    continue;
                end
                object = s.objects(lb);
                mask(object.pixels) = 1;
            end
            mask = mask + s.a.as(i_n).union;
            of_interest = s.a.as(i_n).of_interest;
            
            ipu = numel(find(mask > 1)) / numel(find(mask >= 1));
            if numel(find(mask > 0)) == 0
                ipu = 1;
            end;
            if ipu > 0.5 && of_interest
                if ~is_pronoun
                    right_a = right_a + 1;
                end
                right_a_with_it = right_a_with_it + 1;
            end
        end
        al_nouns = al_nouns + s.a.all_nouns;
        al_nouns_with_it = al_nouns_with_it + s.a.all_nouns_with_it;
    end
end

% compute accuracy

scene_a = sum(diag(Cs)) / sum(Cs(:));
object_a = sum(diag(Co)) / sum(Co(:));
if is_real
    Cn = Co ./ repmat(sum(Co, 2), [1, size(Co, 2)]);
    object_a = mean(diag(Cn));
end;

if use_a
    a_recall = right_a / al_nouns;
    a_precision = right_a / al_preds;
    a_with_it_recall = right_a_with_it / al_nouns_with_it;
    a_with_it_precision = right_a_with_it / al_preds_with_it;
end
    
% create output

R.results = results;
R.scene_accuracy = scene_a;

if use_bias~=1
    R.object_accuracy = object_a;
else
    tp = sum(diag(Co(1:Ko, 1:Ko)));
    fn = sum(sum(Co(1:Ko, :))) - tp;
    fp = sum(Co(Ko+1, 1:Ko));
    
    R.precision = tp / (tp + fp);
    R.recall = tp / (tp + fn) * base_recall;
    R.F1 = 2 * (R.precision * R.recall) / (R.precision + R.recall);
end

R.scene_confusion = Cs;
R.object_confusion = Co;

if use_a
    R.a_recall = a_recall;
    R.a_precision = a_precision;
    R.a_fmeasure = 2 * a_recall * a_precision / (a_recall + a_precision);
    R.a_with_it_recall = a_with_it_recall;
    R.a_with_it_precision = a_with_it_precision;
    R.a_with_it_fmeasure = 2 * a_with_it_recall * a_with_it_precision /...
        (a_with_it_recall + a_with_it_precision);

end

if use_bias
    % class-specific performance
    
    c_tp = zeros(1, Ko);
    c_fn = zeros(1, Ko);
    c_fp = zeros(1, Ko);
    
    for k = 1 : Ko
        c_tp(k) = Co(k, k);
        c_fn(k) = sum(Co(k, :)) - c_tp(k);
        c_fp(k) = Co(Ko+1, k);
    end
    
    R.c_tp = c_tp;
    R.c_fn = c_fn;
    R.c_fp = c_fp;
    
    R.c_precision = c_tp ./ (c_tp + c_fp);        
    R.c_recall = c_tp ./ (c_tp + c_fn) .* c_base_recalls;
    R.c_F1 = 2 * (R.c_precision .* R.c_recall) ./ (R.c_precision + R.c_recall);
    
    R.c_precision(isnan(R.c_precision)) = 0;
    R.c_F1(isnan(R.c_F1)) = 0;
end
