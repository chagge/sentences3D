function Dahua_geometry(objty)
data_globals;

spl = load(SPLIT_FILE);
tv = [spl.train; spl.val]; te = spl.test;
Gs = in3d_gen_geos(objty);
F = p3d_geofea(Gs, tv, te);

cs = [0.05 0.1 0.2 0.5 1 10];
gs = [0.005 0.01 0.02 0.05 0.1 0.2 0.5 1];
[best, Pall] = in3d_geosvm(F, cs, gs); %#ok<ASGLU>
geomodel_fp = fullfile(DATA_OBJTY_DIR, 'geomodel.mat');
save(geomodel_fp, 'best', 'Pall');

load(GTS_FILE);
pots = in3d_divpots(GTs, Pall); %#ok<NASGU>
save(GEOPOTS_FILE, 'pots');