function [feature] = get_feature_size(a, obj)
data_globals;

% label

% feature 
%adjfeat = zeros(1, 3);
%adjfeat(label) = 1;
class_feat = zeros(1, length(SIZE_CLASSES) + 1);
ind = strmatch(a.class, SIZE_CLASSES, 'exact');
if isempty(ind), 
    class_feat(end) = 1; 
else
    class_feat(ind) = 1; 
end;
geoinfo = obj.geoinfo;
feature = [geoinfo.height, geoinfo.lwidth, geoinfo.swidth, geoinfo.haspect,...
    geoinfo.vaspect, geoinfo.area, geoinfo.vol, class_feat];%, adjfeat];

if size(feature,1) ~= 1
    error('size of feature vector is wrong.');
end
if ~isnumeric(feature)
    error('Feature is not a numeric array.');
end
if ~isempty(find(isnan(feature) == 1, 1))
    error('Feature vector contains NaN');
end