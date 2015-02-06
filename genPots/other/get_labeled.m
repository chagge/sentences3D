function labeled = get_labeled(option)
options = {'GTS_DIR', 'FINAL_DIR', 'INFO_DIR'};
if isempty(find(strcmp(option, options), 1))
    error('wrong option, as option is %s', option);
end
if strcmp(option, 'GTS_DIR')
    ttl = 'gt';
end
if strcmp(option, 'FINAL_DIR')
    ttl = [];
end
if strcmp(option, 'INFO_DIR')
    ttl = 'in';
end
data_globals;
data = zeros(1449,1);
for i = 1:1449
    final_file = fullfile(eval(option), sprintf('%s%04d.mat', ttl, i));
    data(i) = 0;
    data(i) =  exist(final_file, 'file');
%     if exist(final_file, 'file')
%         annotation = load(final_file);
%         if isfield(annotation, 'annotation')
%             data(i) =  1;
%         end
%     end
end
labeled = find(data ~= 0);
% split = load(SPLIT_FILE);
% labeled_val = intersect(split.val, labeled);