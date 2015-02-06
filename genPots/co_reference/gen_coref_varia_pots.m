function gen_coref_varia_pots(objty) %#ok<INUSD>
data_globals;

ass = load(AS_FILE);
ass = ass.As;

num_sce = 1449;
pots = cell(1449, 1);

best_cuboid = load(BEST_CUBOID_POTS_FILE);
lists = best_cuboid.list;

for i_sce = 1:num_sce
    as = ass{i_sce};
    list = lists{i_sce};
    num_list = numel(list);
    for j1 = 1:num_list
        id1 = list(j1);
        a1 = as(id1);
        for j2 = j1+1:num_list
            id2 = list(j2);
            a2 = as(id2);
            if isempty(a1.coref)
                continue;
            end;
            [ia, ic] = ismember(a2.id, a1.coref, 'rows');
            if ia
                pot = eye(NUM_CANDIDATE+1) * a1.coref_prob(ic);
                pot(1,1) = 0;
                pots{i_sce}{j1, j2} = pot;
            end
        end
    end
end
save(CV_POTS_FILE, 'pots');