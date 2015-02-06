function gen_size_pots(objty)
if nargin < 1
    objty = 'gt';
end;
%threshold = 'cubdata'; 
data_globals;
disp('Data preparing...');

pots = cell(1449, 1);
gt = cell(1449, 1);
list = cell(1449, 1);
As = load(AS_FILE);
As = As.As;
%segpots = load(CUB_SEGPOTS_FILE);
%segpots = segpots.pots;
geoinfos = load(GEOINFO_FILE);
geoinfos = geoinfos.Gs;
%geopots = load(GEOPOTS_FILE);
%geopots = geopots.pots;
fcls = load(CLASS_FINAL);

disp('Loading Models...');
models = load(SIZE_BEST_MODELS);
best = models.best;
parti = models.norm;

is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end

%parti = load(fullfile(A_CUBOID_DIR, 'norm.mat'));
%parti = models.norm;

for i_sce = 1:1449
    if mod(i_sce-1, 20)==0, fprintf('   doing %d/1449\n', i_sce); end;
    obj_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i_sce));
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
      
    objs = load(obj_file);
    objs = objs.objects;
    [objs, use_inds] = select_obj(objs, fcls, is_final);
    num_objs = numel(objs);
    info = load(info_file);
    %segpot = segpots{i_sce}(use_inds, :);
    %geopot = geopots{i_sce}(use_inds, :);
    geoinfo = geoinfos{i_sce}(use_inds, :);
    
    if isempty(info.descriptions)
        %continue;
    end

    as = As{i_sce};
    num_as = numel(as);
    
    for i_as = 1:num_as
        a = as(i_as);
        label = get_a_size(a, SIZE_LIST_BIG, SIZE_LIST_SMALL);
        bias = 0;
        temp_pot = [];
        temp_gt = [];
        temp_list = [];

        for i_obj = 1:num_objs               
            obj = objs(i_obj);
            if obj.diff || obj.badannot || ~obj.has_cube
                bias = bias + 1;
                continue;
            end
            %obj.segpot = segpot(i_obj, :);
            obj.geoinfo = geoinfo{i_obj};
            %obj.geopot = geopot(i_obj, :);
	        p = 0;
            if label > 0
               [f_vector] = get_feature_size(a, obj);
	           f_vector = f_vector ./ parti;
               [~, ~, p] = svmpredict(1, f_vector, best{label}.model, '-q');
            end;
            temp_pot(i_obj - bias) = p; %#ok<*AGROW>
%            temp_gt(i_obj - bias) = lb;
            temp_list = ones(1,a.cardinality)*i_as;
        end
        pots{i_sce} = [pots{i_sce}; repmat(temp_pot, [a.cardinality, 1])];
       % gt{i_sce} = [gt{i_sce}; repmat(temp_gt, [a.cardinality, 1])];
        list{i_sce} = [list{i_sce} ,temp_list]; 
    end    
end
save(SIZE_O_POTS_FILE, 'pots', 'list');%, 'gt');
%select_candidates(threshold, objty);

function label = get_a_size(a, SIZE_LIST_BIG, SIZE_LIST_SMALL)

adjs = a.adj;
pla = ismember(adjs, SIZE_LIST_BIG);
if sum(pla) ~= 0;
    label = 2;
else
    pla = ismember(adjs, SIZE_LIST_SMALL);
    if sum(pla) ~= 0;
        label = 1;
    else
        label = 0;
    end
end
