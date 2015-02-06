function select_candidates(objty) %#ok<INUSD>
data_globals;
num = NUM_CANDIDATE;

best_cuboid = load(BEST_CUBOID_O_POTS_FILE);
size_cuboid = load(SIZE_O_POTS_FILE);
pots_o = best_cuboid.pots;
labels_o = best_cuboid.gt;
size_pots_o = size_cuboid.pots;
list = best_cuboid.list;
pots = cell(1449, 1);
pots_size = cell(1449, 1);
gts = cell(1449, 1);
cands = cell(1449, 1);
for i_sce = 1:1449
    p = pots_o{i_sce};
    p_size = size_pots_o{i_sce};
    l = labels_o{i_sce};
    if isempty(p)
        pots{i_sce} = [];
        cands{i_sce} = [];
        gts{i_sce} = [];
        list{i_sce} = [];
        continue;
    end
    if size(p, 2) < num
        pp = [p, ones(size(p, 1), num - size(p, 2)) * (-1000)];
        pp_size = [p_size, ones(size(p_size, 1), num - size(p_size, 2)) * (-1000)];
        cand = [repmat(1:size(p, 2),[size(p, 1), 1]), zeros(size(p, 1), num - size(p, 2))];
        ll = [l, zeros(size(p, 1), num - size(p, 2))];
    else
        [pp, cand] = sort(p, 2, 'descend');
        pp = pp(:, 1:num);
        pp_size = p_size(:, cand(1:num));
        cand = cand(:, 1:num);
        ll = zeros(size(pp, 1), num);
        for i = 1:size(pp, 1)
            ll(i, :) = l(i,cand(i,:));
        end
    end
    pots{i_sce} = [zeros(size(pp, 1), 1), pp];
    pots_size{i_sce} = [zeros(size(pp_size, 1), 1), pp_size];
    cands{i_sce} = [zeros(size(cand, 1), 1), cand];
    gt = [ones(size(ll, 1), 1) - max(ll,[], 2), ll];
    gt(gt < 0) = 0;
    gts{i_sce} = gt;
end
save(BEST_CUBOID_POTS_FILE, 'pots', 'gts', 'num', 'list');
pots = pots_size;
save(SIZE_POTS_FILE, 'pots', 'gts', 'num', 'list');
save(CANDIDATE_CUBOIDS_FILE, 'cands');