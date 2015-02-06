function plot_Kc(scene_index, toplot, doexport)
objty = 'gt'; 
data_globals;
plotgt = toplot;
clsdata = load(CLASS_FINAL);
classes = clsdata.classes;
map = clsdata.reduced_to_final;
scenedata = load(fullfile(ROTSCE_DIR, sprintf('sc%04d.mat', scene_index)));
gtcubedata = load(fullfile(OBJ_DIR, sprintf('%04d.mat', scene_index)));
im = imread(fullfile(IMAGE_DIR, sprintf('%04d.jpg', scene_index)));
scenedata.image = im;
% info_file = fullfile(INFO_DIR, sprintf('in%04d.mat', scene_index));
% info = load(info_file);
% is_final = 1;
% if strcmpi(objty, 'gt') 
%     is_final = 0;
% end
% As = load(AS_FILE);
% as = As.As{scene_index};
% if strcmp(objty, 'gt')
%     cfg = '6';
% end
% result_file = fullfile(DATADIR, 'result', cfg, 'C1.0e-02', 'results_test.a0.mat');
% result = load(result_file);
% split = load(SPLIT_FILE);
% id = split.test == scene_index;
% results = result.results(id);
fprintf('scene index: %d\n', scene_index);
% [gtcubedata.objects, ~] = select_obj(gtcubedata.objects, clsdata, is_final);
% assert(numel(gtcubedata.objects) == numel(results.object_labels))
if plotgt
   for i = 1 : length(gtcubedata.objects)
       gtcubedata.objects(i).label = map(gtcubedata.objects(i).label);
   end;
%    plot_cubes(scenedata, gtcubedata.objects, classes, info, as, results);
    plot_cubes(scenedata, gtcubedata.objects, classes);
   if doexport
      saveas(gcf, fullfile(FIGURE_DIR, sprintf('gt%04d.png', scene_index)))
   end
end;


function h = plot_cubes(scenedata, objects, classes, labels)

which = 1;

if which ==1
 %p3d_view_s(scenedata, 'rgb-world')
 w = size(scenedata.image, 2);
 h = size(scenedata.image, 1);
%  h=figure('position', [100,100,w, 600]);
 h=figure('position', [100,100,w, h]);
 subplot('position', [0,0.2,1,0.8]);
 imshow(scenedata.image);
 f = 1;
 minPoint = [0,0,0];
else
   minPoint = plot3d_vox(scenedata);
   f = 0.01;
end;
j = 0;
col = cubelabelmap();
%col = VOClabelcolormap;
for i = 1 : length(objects)
    if nargin < 4
       label = objects(i).label;
    else
        label = labels(i);
    end;
    if label <= numel(classes) && label > 0 && ~isempty(objects(i).cube)
        j = j+1;
       cube = objects(i).cube;
       cube.dims = cube.dims / f;
       cube.centers = (cube.centers - minPoint)/f;
       %p3d_drawcube_s(cube, 1, label, classes{label}, dotext)
       [~, ~, ~, boxView] = p3d_projcube_s(scenedata, cube);%, col(label, :));
       plot_boxView([], {boxView}, col(j, :))
    end;
end;
% subplot('position', [0,0,1,0.2]);
% rectangle('Position',[70,0,w-80,600-h],...
%     'FaceColor',[0.9,1,1], 'EdgeColor', 'none');
% sentences = info.descriptions.sentences;
% locx = 70;
% locy = 500;
% fontsize = 10.4;
% rowwid = w;
% fontname = 'Apple Color Emoji';
% for i = 1:numel(sentences);
%     sentence = sentences{i};
%     for j = 1:numel(sentence)
%         word = sentence{j};
%         if strcmp(word, '$')
%             word = ',';
%             locx = locx - 7;
%         end
%         if locx + getsize(word) > rowwid
%             locx = 70;
%             locy = locy - 90;
%         end
%         text(locx, locy, word, 'FontSize',fontsize,...
%             'FontWeight', 'bold', 'FontName', fontname,...
%             'HorizontalAlignment', 'left')
%         locx = locx + getsize(word);
%     end
%     locx = locx - 7;
%     text(locx, locy, '.', 'FontSize',fontsize,...
%         'FontWeight', 'bold', 'FontName', fontname,...
%         'HorizontalAlignment', 'left')
%     locx = locx + 10;
% end
%    
% 
% function width = getsize(word)
% smallletterwidth = 5.8+1;
% letterwidth = 6.2+1;
% bigletterwidth = 7.7+1;
% num = 1; numbig = 0; numsmall = 0;
% for k = 1 : length(word)
%    if strcmp(lower(word(k)), word(k)) && ~strcmp(word(k), 'w')% && ~strcmp(word(k), 'a')
%        if strcmp(word(k), 'l') || strcmp(word(k), 'i') || ...
%                strcmp(word(k), 'j') || strcmp(word(k), 'g') || ...
%                strcmp(word(k), 't')
%            numsmall = numsmall + 1;
%        else
%           num = num+1;
%        end;
%    else
%        numbig = numbig+1;
%    end;
% end;
% width = num * letterwidth + numbig * bigletterwidth + numsmall * smallletterwidth;
