function plotResults1(n, toplot, doexport)

plotgt = toplot(1);
plotcube = toplot(2);
root = '~/science/data/3D/nyu';
outdir = '/Users/sanja/science/clanki/detector_RGBD/figs';
clsdata = load(fullfile(root, 'classes_final.mat'));
classes = clsdata.classes;
map = clsdata.reduced_to_final;
%scenedir = fullfile(root, 'rot_scenes_all');
scenedir = fullfile(root, 'rot_scenes');
gtcubedir = fullfile(root, 'gtobjects_a');
cubedir = fullfile(root, 'cubes_nms');
imdir = fullfile(root, 'images');

resultdata = load(fullfile(root, 'results', 'viz_results.mat'));
cubedata = resultdata.R{n};
scene_index = cubedata.scene_index;
scenedata = load(fullfile(scenedir, sprintf('sc%04d.mat', scene_index)));
gtcubedata = load(fullfile(gtcubedir, sprintf('%04d.mat', scene_index)));
im = imread(fullfile(imdir, sprintf('%04d.jpg', scene_index)));
alldata = load(fullfile(root, 'scenes', sprintf('s%04d.mat', scene_index)));
scenedata.image = im;
depth = alldata.depths;
%cubedata = load(fullfile(cubedir, sprintf('%04d.mat', n)));


fprintf('scene index: %d\n', scene_index);

 w = size(scenedata.image, 2);
 h = size(scenedata.image, 1);
 figure('position', [100,100,w, h]);
 subplot('position', [0,0,1,1]);
 h=imshow(scenedata.image);
    if doexport
      %export_fig(sprintf('/Users/sanja/science/clanki/detector_RGBD/figs/im%04d.png', scene_index)) 
      saveas(h, fullfile(outdir, sprintf('im%04d.png', scene_index)))
    end
    
 w = size(depth, 2);
 h = size(depth, 1);
 figure('position', [100,100,w, h]);
 subplot('position', [0,0,1,1]);
 h=imagesc(depth);
    if doexport
      %export_fig(sprintf('/Users/sanja/science/clanki/detector_RGBD/figs/im%04d.png', scene_index)) 
      saveas(h, fullfile(outdir, sprintf('depth%04d.png', scene_index)))
    end

%return;
% GT
if plotgt
   %figure(2);
   for i = 1 : length(gtcubedata.objects)
       gtcubedata.objects(i).label = map(gtcubedata.objects(i).label);
   end;
   h=plot_cubes(scenedata, gtcubedata.objects, classes);
   if doexport
      %export_fig(sprintf('/Users/sanja/science/clanki/detector_RGBD/figs/gt%04d.png', scene_index))
      saveas(h, fullfile(outdir, sprintf('gt%04d.png', scene_index)))
   end
end;

if plotcube
%figure(3);
objects = [];
for i = 1 : cubedata.nr
    objects(i).cube = cubedata.result_cubes(i);
end;
h=plot_cubes(scenedata, objects, classes, cubedata.result_labels);
   if doexport
      %export_fig(sprintf('/Users/sanja/science/clanki/detector_RGBD/figs/det%04d.png', scene_index))
      saveas(h, fullfile(outdir, sprintf('det%04d.png', scene_index)))
   end
end;


function h=plot_cubes(scenedata, objects, classes, labels)

which = 1;

if which ==1
 %p3d_view_s(scenedata, 'rgb-world')
 w = size(scenedata.image, 2);
 h = size(scenedata.image, 1);
 h=figure('position', [100,100,w, h]);
 subplot('position', [0,0,1,1]);
 imshow(scenedata.image);
 f = 1;
 minPoint = [0,0,0];
 dotext = 0;
else
   minPoint = plot3d_vox(scenedata);
   f = 0.01;
   dotext = 1;
end;

col = cubelabelmap();
%col = VOClabelcolormap;
for i = 1 : length(objects)
    if nargin < 4
       label = objects(i).label;
    else
        label = labels(i);
    end;
    if label <= length(classes) && label > 0 && ~isempty(objects(i).cube)
       cube = objects(i).cube;
       cube.dims = cube.dims / f;
       cube.centers = (cube.centers - minPoint)/f;
       %p3d_drawcube_s(cube, 1, label, classes{label}, dotext)
       [ix, iy, cubeinfo, boxView] = p3d_projcube_s(scenedata, cube);%, col(label, :));
       plot_boxView([], {boxView}, col(label, :))
    end;
end;


function plot_cubes3d(scenedata, objects, classes, labels)

which = 1;

if which ==1
 p3d_view_s(scenedata, 'rgb-world')
 f = 1;
 minPoint = [0,0,0];
 dotext = 0;
else
   minPoint = plot3d_vox(scenedata);
   f = 0.01;
   dotext = 1;
end;

for i = 1 : length(objects)
    if nargin < 4
       label = objects(i).label;
    else
        label = labels(i);
    end;
    if label <= length(classes) && label > 0 && ~isempty(objects(i).cube)
       cube = objects(i).cube;
       cube.dims = cube.dims / f;
       cube.centers = (cube.centers - minPoint)/f;
       p3d_drawcube_s(cube, 1, label, classes{label}, dotext)
    end;
end;

%set(gca,'CameraUpVector',[0.0431    0.9877    0.1504])
%set(gca,'CameraPosition',[-5.0090    2.2660  -12.3660])
%set(gca,'CameraViewAngle', 7.8159)
%zoom(1.)

