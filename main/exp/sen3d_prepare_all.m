function sen3d_prepare_all(objty)
% Prepare everything needed for a experiment on a specific cube set
%
%   SEN3D_PREPARE_ALL(objty);

data_globals;

if ~exist(GTS_FILE, 'file')
    display('Compiling ground-truths ...');
    sen3d_compilegts(objty);
else
    display('Ground-truths existed.');
end

if ~exist(COSTAT_FILE, 'file')
    display('Generating co-stats ...');
    sen3d_costats(objty);
else
    display('Co-stats existes.');
end

if ~exist(CUB_SEGPOTS_FILE, 'file')
    display('Generating segmentation potentials ...');
    sen3d_segpots(objty);
else
    display('Segmentation potentials existed.');
end

if ~exist(GEOPOTS_FILE, 'file')
    display('Generating geometry features ...');
    Dahua_geometry(objty);
else
    display('Geometry features existed.');
end

if ~exist(OBJ_C_DIR, 'dir')
    display('Adding color score for objects...');
    asign_color_obj(objty);
else
    display('Color score added.');
end

if ~exist(INFO_DIR, 'dir')
    display('Parsing and Extracting info from descriptions...');
    extract_info();
    display('Adding Co-reference...');
    parse_mohit();
else
    display('descriptions_info existed.');
end

if ~exist(AS_FILE, 'file')
    display('Collecting data for variable a...');
    gen_As();
else
    display('as.mat existed.');
end

if ~exist(SCENETEXT_FILE, 'file')
    display('Generating scene text potentials...');
    gen_sce_text_pot(objty);
else
    display('Scene text potentials existed.');
end
 
if ~exist(SIZE_O_POTS_FILE, 'file')
    display('Generating size potentials...');
    gen_size_pots(objty);
else
    display('Size potentials existed.');
end

if ~exist(BEST_CUBOID_POTS_FILE, 'file')
    display('Generating best cuboid potentials...');
    gen_bcub_pots(objty);
    display('Selecting candidates')
    select_candidates(objty)
else
    display('Best cuboid potentials existed.');
end

if ~exist(CV_POTS_FILE, 'file')
    display('Generating coreference and variety potentials...');
    gen_coref_varia_pots(objty);
else
    display('Coreference and variety potentials existed.');
end

display('Updating Dataset of Model...');
sen3d_genset(objty);

display('Experiment dataset generated!');

