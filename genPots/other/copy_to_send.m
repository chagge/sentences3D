function copy_to_send()
data_globals;
split = load(split_file);
val = split.val;

for i_val = 1:numel(val)
    i_sce = val(i_val);
    file = fullfile(final_dir, sprintf('%04d.mat', i_sce));
    try
        load(file);
    catch
        continue;
    end
    to_file = fullfile(to_send_dir, sprintf('%04d.mat', i_sce));
    save(to_file, 'annotation');
end