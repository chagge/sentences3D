if exist('/share/data/sentences3D', 'dir')
    % data path in Raquel's machine
    ROOT = '/share/data/sentences3D';
    DATADIR = fullfile(ROOT, 'data');
    CODESDIR = '/home-nfs/kongchen/sentences3D/codes';
else
    % data path in my machine
    ROOT = '/Users/kongchen/GitHub/sentences3D';
    DATADIR = fullfile(ROOT, 'data');
    CODESDIR = fullfile(ROOT, 'codes');
end
RESULTDIR = fullfile(DATADIR, 'result');
SPLIT_FILE = fullfile(DATADIR, 'split.mat');
FINAL_DIR = fullfile(DATADIR, 'descriptions');
TO_SEND_DIR = fullfile(DATADIR, 'to_send');
CLSF_DIR = fullfile(DATADIR, 'classifiers');

INFO_DIR = fullfile(DATADIR, 'descriptions_info');
COLOR_DIR = fullfile(DATADIR, 'descriptors', 'color');
BEST_COLOR_MODELS_FILE = fullfile(CLSF_DIR, 'best_color_models.mat');
A_CUBOID_DIR = fullfile(DATADIR, 'a_cuboid');
if exist('objty', 'var') && ~strcmp(objty, 'gt')
    %A_CUBOID_DIR = fullfile(DATADIR, 'a_cuboid', objty);
end;
CANDIDATE_MODELS_FILE = fullfile(A_CUBOID_DIR, 'best_candidate_models.mat');
CLASS_FINAL = fullfile(DATADIR, 'classes_final.mat');
CLASS_REDUCED = fullfile(DATADIR, 'classes_reduced.mat');
SCENE_CLASSES = fullfile(DATADIR, 'scene_classes.mat');
OURLABELS_DIR = fullfile(DATADIR,'data/segmentation/ourlabels');
OVERLAP_DIR = fullfile(DATADIR,'data/overlaps');
CANDIDATE_CUBOIDS_FILE = fullfile(A_CUBOID_DIR, 'candidate_cuboids.mat');
NUM_CANDIDATE = 20;
AS_FILE = fullfile(A_CUBOID_DIR, 'as.mat');
AS_STATS_FILE = fullfile(A_CUBOID_DIR, 'as_cuboid_stats.mat');
SCENEPOT_FILE = fullfile(DATADIR, 'scene_pots.mat');
SCENETEXT_FILE = fullfile(DATADIR, 'scene_text_potential.mat');
GTS_DIR = fullfile(DATADIR, 'descriptions_gt');
SCENETEXT_BEST_FILE = fullfile(CLSF_DIR, 'sce_text_best.mat');
WORD_FEATURE_REDUCED = fullfile(DATADIR, 'parser',  'word_feature_reduced.mat');
HIST_ADJ_FILE = fullfile(DATADIR, 'histogram_adj.mat');
HIST_SIZE_FILE = fullfile(DATADIR, 'histogram_size.mat');
SIZE_DIR = fullfile(DATADIR, 'size');
SIZE_BEST_MODELS = fullfile(CLSF_DIR, 'best_size_models.mat');
COREF_DIR = fullfile(DATADIR, 'coref');
STATISTIC_DIR = fullfile(DATADIR, 'statistic');
STATISTIC_COREF = fullfile(STATISTIC_DIR, 'statistic_coref.mat');
CV_POTS_FILE = fullfile(A_CUBOID_DIR, 'cv_pots');
PREP_DIR = fullfile(DATADIR, 'preposition');
SEGPRED_DIR = fullfile(DATADIR, 'segPredictions');
SPSEG_DIR = fullfile(DATADIR, '/UCM/SuperSegments');
SPGT_DIR = fullfile(DATADIR, '/data/segmentation/ourlabels');
ROTSCE_DIR = fullfile(DATADIR, 'DahuaGeometry',  'rot_scenes');   
PREP_BEST_MODELS = fullfile(PREP_DIR, 'best.mat');
HUMAN_FILE = fullfile(DATADIR, 'human_accuracy.mat');
IMAGE_DIR = fullfile(DATADIR, 'images');
FIGURE_DIR = fullfile(DATADIR, 'fig');
SCENE_DIR = fullfile(DATADIR, 'scenes');
if exist('objty', 'var')
%     OBJ_DIR = fullfile(DATADIR, sen3d_getobjdir(objty));
    OBJ_C_DIR = fullfile(DATADIR, [sen3d_getobjdir(objty), '_c']);
    OBJ_DIR = OBJ_C_DIR;
    OBJ_R_DIR = fullfile(DATADIR, 'gtobjects_reduced');
    DATA_OBJTY_DIR = fullfile(DATADIR, objty);
    DATASETFILE_REAL = fullfile(DATADIR, 'NNdata', objty, 'dataset_globals');
    if ~exist(DATA_OBJTY_DIR, 'dir')
        mkdir(DATA_OBJTY_DIR);
    end
    GTS_FILE = fullfile(DATA_OBJTY_DIR, 'ground_truths.mat');
    COSTAT_FILE = fullfile(DATA_OBJTY_DIR,'co_stats.mat');
    CUB_SEGPOTS_FILE = fullfile(DATA_OBJTY_DIR, 'segpots.mat');
    GEOINFO_FILE = fullfile(DATA_OBJTY_DIR, 'geoinfo.mat');
    GEOPOTS_FILE = fullfile(DATA_OBJTY_DIR, 'geopots.mat');
    BEST_CUBOID_O_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'best_cuboid_o_pots.mat');
    SIZE_O_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'size_o_pots.mat');
    BEST_CUBOID_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'best_cuboid_pots.mat');
    SIZE_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'size_pots.mat');
    CV_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'cv_pots.mat'); 
    DATASET_FILE = fullfile(DATA_OBJTY_DIR, 'dataset.mat');
    DATAFILES_OBJTY_DIR = fullfile(DATA_OBJTY_DIR, 'files');
    PREP_POTS_FILE = fullfile(DATA_OBJTY_DIR, 'prep_pots.mat');
    if exist('threshold', 'var')

        DATA_THRES_DIR = fullfile(DATA_OBJTY_DIR, threshold);
        DATASET_DIR = fullfile(DATA_THRES_DIR, 'dataset');
        if ~exist(DATASET_DIR, 'dir');
            mkdir(DATASET_DIR);
        end
        
        SEN3D_SEGPOT_DIR = fullfile(DATA_THRES_DIR, 'rgbdt_segpot');
        SEN3D_CMPTPOT_DIR = fullfile(DATA_THRES_DIR, 'rgbdt_cmptpot');
        SEN3D_DATASET_FILE = fullfile(DATA_THRES_DIR, 'dataset_sp.mat');
            

        SPSEG_THRES_DIR = fullfile(SPSEG_DIR,sprintf('SuperSegment%s', threshold));

    end
end

COLOR_LIST = {'white', 'blue', 'red', 'black', 'brown', 'bright'};

POSITION_LIST{1} = {'next_to wall', 'next wall', 'near wall', 'by wall'};
POSITION_LIST{2} = {'in background'};
POSITION_LIST{3} = {'in foreground'};
POSITION_LIST{4} = {'in center', 'middle room', 'in middle', 'center room'};
POSITION_LIST{5} = {'in corner', 'corner room'};
POSITION_LIST{6} = {'on floor'};
POSITION_LIST{7} = {'on wall'};
POSITION_LIST{8} = {'to left', 'left picture', 'left photo', 'left room'};
POSITION_LIST{9} = {'to right', 'right picture', 'right photo', 'right room'};

SIZE_LIST_BIG = {'big', 'long', 'large',  'thick', 'tall', 'wide', ...
    'huge', 'double', 'double-size', 'king'};
SIZE_LIST_SMALL = {'small', 'short', 'tiny', 'narrow', 'single'};
SIZE_LIST = [SIZE_LIST_BIG, SIZE_LIST_SMALL];
SIZE_CLASSES = {'bed', 'table', 'shelf', 'cabinet', 'sofa'};   % big objects

NUM_CLASSES = 21;

PRO_LIST = {'it', 'they', 'them', 'It', 'They', 'Them'};
% PRO_LIST = {};

PREP_LIST{1} = {'top', 'on_top_of'};
PREP_LIST{2} = {'right', 'Right'};
PREP_LIST{3} = {'left', 'Left'};
% PREP_LIST{4} = {'in_front_of', 'front', 'Front'};