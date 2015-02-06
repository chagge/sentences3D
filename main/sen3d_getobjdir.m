function subdir = sen3d_getobjdir(objty)
%SEN3D_GETOBJDIR Get object directory according to type
%
%   SEN3D_GETOBJDIR(datadir, objty);
%
%   Here, objty can be either 'gt', 'nn08', or 'nn15'
%
dir = 'ObjData';
switch lower(objty)
    case 'gt'
        subdir = fullfile(dir, 'gtobjects_a'); 
    case 'nn08'
        subdir = fullfile(dir, 'nn08_objects');
    case 'nn15'
        subdir = fullfile(dir, 'nn15_objects');
    case 'nn30'
        subdir = fullfile(dir, 'nn30_objects');
%     case 'nn50'
%         subdir = fullfile(dir, 'nn50_objects');        
    otherwise
        error('Unknown object type %s', objty);
end