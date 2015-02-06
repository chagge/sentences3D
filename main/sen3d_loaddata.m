function Data = sen3d_loaddata(objty)
%SEN3D_GENSET Generates a scene struct dataset
%
%   R = SEN3D_GENSET(threshold);
%

data_globals;
Data = load(DATASET_FILE);
scenedata = load(SCENETEXT_FILE);
datafile = fullfile(DATA_OBJTY_DIR, sprintf('%s_data.mat', objty));
data = load(fullfile(AS_STATS_FILE));

if exist(datafile, 'file')
    fprintf('Loading all data from %s\n', datafile);
    data = load(datafile);
    Data.S = data.Data.S;
    Data.stats = data.Data.stats;
else
    for i = 1 : 1449     
        if mod(i-1,50)==0, fprintf('   loaded %d/%d\n', i, 1449); end;
        file = fullfile(DATAFILES_OBJTY_DIR, sprintf('ds%04d.mat', i));
        Data.S(i) = load(file, 'scene_label', 'scene_pots', 'scene_text', 'use_inds', 'objects', 'a');
        Data.S(i).scene_text = scenedata.scene_text_pot(i, :);
        Data.S(i).scene_label = scenedata.gt(i);
    end
    fprintf('Saving all data to %s\n', datafile);
    Data.stats = data.stats;
    save(datafile, 'Data', '-v7.3')
end;