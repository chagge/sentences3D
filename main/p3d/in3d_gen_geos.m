function Gs = in3d_gen_geos(objty) 
%Generat all geometric analysis
%
data_globals;
yfs = load(fullfile(DATADIR, 'DahuaGeometry', 'yfloors.mat'));
yfs = yfs.yfloors;

fcls = load(CLASS_FINAL);

n = 1449;
Gs = cell(1, n);

is_final = 1;
if strcmpi(objty, 'gt') 
    is_final = 0;
end

for i = 1 : n
    if mod(i, 50) == 0
        fprintf('Working on %d ...\n', i);
    end
    Gs{i} = gf_on(objty, i, yfs(i));
    
    for j = 1 : length(Gs{i})
        if ~isempty(Gs{i}{j})
            l = Gs{i}{j}.label;
            if ~is_final && l > 0
                Gs{i}{j}.label = fcls.reduced_to_final(l);
            end
        end
    end
end

save(GEOINFO_FILE, 'Gs');


function G = gf_on(objty, idx, yf)
data_globals;
walldir = fullfile(DATADIR,  'DahuaGeometry', 'rf');

sc = load(fullfile(ROTSCE_DIR, sprintf('sc%04d.mat', idx)));
g = load(fullfile(OBJ_DIR, sprintf('%04d.mat', idx)));

wfile = fullfile(walldir, sprintf('rf%04d.mat', idx));
if exist(wfile, 'file')
    walls = load(wfile);
    walls = walls.rf;
else
    walls = {};
end

G = p3d_geoextract(sc, g.objects, walls, yf);
