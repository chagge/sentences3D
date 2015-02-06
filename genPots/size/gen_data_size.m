function [label_vector, instance_matrix] = gen_data_size(objty, set)
label_vector = cell(2,1); % small
instance_matrix = cell(2,1); % big
data_globals;

geoinfos = load(GEOINFO_FILE);
geoinfos = geoinfos.Gs;
fcls = load(CLASS_FINAL);

As = load(AS_FILE);
As = As.As;

is_final = 1;

if strcmpi(objty, 'gt') 
    is_final = 0;
end

for i_set = 1:numel(set)
    i_sce = set(i_set);
    
    if mod(i_set, 50) == 0
        fprintf('Processed %d/ %d\n', i_set, numel(set));
    end
    
    obj_file = fullfile(OBJ_C_DIR, sprintf('%04d.mat', i_sce));  
    info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', i_sce));
    
    objs = load(obj_file);
    objs = objs.objects;
    [objs, use_inds] = select_obj(objs, fcls, is_final);
    num_objs = numel(objs);
    
    geoinfo = geoinfos{i_sce}(use_inds, :);
    
    as = As{i_sce};
    num_as = numel(as);
    
    for i_as = 1:num_as
        a = as(i_as);
        label = get_a_size(a, SIZE_LIST_BIG, SIZE_LIST_SMALL);
        %if ~strcmp(a.class, 'table')
        %    continue;
        %end
        if label == 0
            continue;
        end;
        if isempty(a.segs)
            continue;
        end
        mask = double(a.union);
        for i_objs = 1:num_objs
            obj = objs(i_objs);
            if obj.diff || obj.badannot || ~obj.has_cube
                continue;
            end
            mask_o = mask;
            mask_o(obj.pixels) = mask_o(obj.pixels) + 1;
            ipu = numel(find(mask_o > 1)) / numel(find(mask_o >= 1));
            %if ipu < 0.5
            %    continue;
            %end
            obj.geoinfo = geoinfo{i_objs};
            [f_vector] = get_feature_size(a, obj);
            label_vector{label} = [label_vector{label}; 2 * double(ipu > 0.4) - 1];
            instance_matrix{label} = [instance_matrix{label}; f_vector];
        end
    end 
end
if size(label_vector,1) ~= size(instance_matrix, 1)
    error('sizes of labels and instances are inconsistent...');
end



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
