function pots = sen3d_segpots(objty) %#ok<INUSD>
%IN3D_SEGPOT Generates segmentation potentials for objects
%
%   pots = IN3D_SEGPOTS(objs, seg)
%
%       objs is an array of object structs.
%
%       seg is the segmentation prediction. 
%
%

%% main
data_globals;
final_cls = load(CLASS_FINAL);
final_list = final_cls.final_to_reduced;
other_list = find(~final_cls.in_final);

n = 1449;

pots = cell(n, 1);

is_gt = 1;

for i = 1 : n
    objs = load(fullfile(OBJ_DIR, sprintf('%04d.mat', i)));
    objs = objs.objects;
    
    seg = load(fullfile(SEGPRED_DIR, sprintf('%04d.mat', i)));
        
    Ri = segpot(objs, seg);
    assert(size(Ri, 1) == length(objs) && size(Ri, 2) == 32);
    
    if is_gt
        %pots{i} = Ri(:, final_list);
        pots{i} = [Ri(:, final_list) max(Ri(:, other_list), [], 2)];
    else
        pots{i} = [Ri(:, final_list) max(Ri(:, other_list), [], 2)];  %#ok<UNRCH>
    end        
    
    if mod(i, 20) == 0
        fprintf('%d finished\n', i);
    end
end

save(CUB_SEGPOTS_FILE, 'pots');


function R = segpot(objs, seg)

K = size(seg.pot, 2);

n = length(objs);
R = zeros(n, K);

for i = 1 : n
    o = objs(i);
    
    L = seg.seg(o.pixels);
    R(i, :) = sum(seg.pot(L, :), 1) / length(L);    
end


