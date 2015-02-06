function [label_vector, instance_matrix] = balance_dataset(label_vector_o, instance_matrix_o)
label_vector = [];
instance_matrix = [];

clabels = max(label_vector_o);
size_classes = zeros(clabels, 1);
id_cls = cell(clabels, 1);
for i_cls = 1:clabels
    id_cls{i_cls} = find(label_vector_o == i_cls);
    size_classes(i_cls) = numel(id_cls{i_cls});
end
size_class = min(size_classes);

for i_cls = 1:clabels
    id = randsample(id_cls{i_cls}, size_class);
    label_vector = [label_vector; label_vector_o(id)]; %#ok<*AGROW>
    instance_matrix = [instance_matrix; instance_matrix_o(id, :)];
end

if size(label_vector,1) ~= size(instance_matrix,1)
    error('sizes of label and instance are not consistent.');
end

if ~isnumeric(instance_matrix)
    error('Feature is not a numeric array.');
end

if ~isempty(find(isnan(instance_matrix) == 1, 1))
    error('Feature vector contains NaN');
end