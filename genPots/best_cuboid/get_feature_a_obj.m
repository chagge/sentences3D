function [label, feature] = get_feature_a_obj(a, obj, label)
% label
% if ~a.obj_id
%     label = 0;
% else
%     if nargin < 3
%         if isfield(obj, 'mask')
%             mask = obj.mask;
%         else
%             mask = zeros(480, 640);
%             mask(obj.pixels) = 1;
%         end;
%         if ~isfield(a, 'mask')
%             mask_a = roipoly(zeros(480, 640), a.seg(:, 1), a.seg(:, 2));
%         else
%             mask_a = a.mask;
%         end;
%         mask = mask + mask_a;
%         label = numel(find(mask >1)) / numel(find(mask >=1));
%     end;
% end


% feature    
data_globals;
obj.segpot = obj.segpot(1:NUM_CLASSES);
segpot = obj.segpot'/ sum(obj.segpot);
geopot = obj.geopot' / sum(obj.geopot);
geoinfo = obj.geoinfo;
if geoinfo.walldist == inf
    geoinfo.walldist = 15;
end
geofeature = [geoinfo.height; geoinfo.lwidth; geoinfo.swidth; geoinfo.haspect;...
    geoinfo.vaspect; geoinfo.area; geoinfo.vol; geoinfo.iwall; geoinfo.wallrad;...
    geoinfo.walldist; geoinfo.grounddist];
color = obj.color' / norm(obj.color);
p = [640; 640; 480; 480];
bbx = obj.bndbox'./p;
position_2d = [bbx; mean(bbx([1,2])); mean(bbx([3,4]))]; 
cube = obj.cube;
p = 10;
position_3d = cube.centers' /p;
lb = a.class_id_final;
class_feat = zeros(NUM_CLASSES, 1);
if lb > NUM_CLASSES
    %fprintf('error!\n');
else
class_feat(lb) = 1;
end;
adj_color = zeros(numel(COLOR_LIST),1);
for i_a = 1:numel(a.adj)
    adj = a.adj{i_a};
    i = find(strcmp(adj, COLOR_LIST));
    if ~isempty(i)
        adj_color(i) = 1;
    end
end
num_posi = numel(POSITION_LIST); %#ok<USENS>
posi_text = zeros(num_posi, 1);
num_prep = numel(a.posi);
for j = 1:num_prep
    for i = 1:num_posi
        if ~isempty(find(strcmp(POSITION_LIST{i}, a.posi{j}), 1))
            posi_text(i) = 1;
        end
    end
end
feature = [segpot(1:NUM_CLASSES); geopot; geofeature; color; position_2d; position_3d;...
    class_feat; adj_color; posi_text];
feature = feature';

% if size(label,1) ~= 1
%     error('size of label is wrong.');
% end
if size(feature,1) ~= 1
    error('size of feature vector is wrong.');
end
if ~isnumeric(feature)
    error('Feature is not a numeric array.');
end
if ~isempty(find(isnan(feature) == 1, 1))
    error('Feature vector contains NaN');
end