function [label_vector, instance_matrix, norm] = balance_a_cuboid(label_vector_o, instance_matrix_o, objty, istrain)
data_globals;

if nargin < 4
    istrain = 0;
end;

id_positive = find(label_vector_o == 1);
num_positive = numel(id_positive);

id_negative = find(label_vector_o == -1);
num_negative = numel(id_negative);

if num_negative > 1 * num_positive

    label_vector = label_vector_o(id_positive);
    instance_matrix = instance_matrix_o(id_positive, :);

    id_nega_n = randsample(id_negative, min(length(id_negative), round(1* num_positive)));
    label_vector = [label_vector; label_vector_o(id_nega_n)];
    instance_matrix = [instance_matrix; instance_matrix_o(id_nega_n, :)];
else
    label_vector = label_vector_o;
    instance_matrix = instance_matrix_o;
end

instance_matrix(instance_matrix == Inf) = 10;

if strcmp(objty, 'gt')
    file = fullfile(A_CUBOID_DIR, 'norm.mat');
else
    file = fullfile(A_CUBOID_DIR, objty, 'norm.mat');
end;

if ~istrain
    load(file);
else
    norm = sum(instance_matrix.^2, 1).^0.5;
    norm(norm < 2 * eps) = 1;
    save(file, 'norm');
end

part = repmat(norm, [size(instance_matrix, 1), 1]);
instance_matrix = instance_matrix ./ part;

if size(label_vector,1) ~= size(instance_matrix,1)
    error('sizes of label and instance are not consistent.');
end

if ~isnumeric(instance_matrix)
    error('Feature is not a numeric array.');
end

if ~isempty(find(isnan(instance_matrix) == 1, 1))
    error('Feature vector contains NaN');
end