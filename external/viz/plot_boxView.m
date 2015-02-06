function plot_boxView(im, boxView, col)

if ~isempty(im)
imshow(im);
end;
hold on;

if ~iscell(boxView)
  temp{1} = boxView;
  boxView = temp;
end;
faces = faces_for_box();

for i = 1 : length(boxView)
hx = boxView{i}(1, :);
hy = boxView{i}(2, :);
vis = boxView{i}(3,:);

%h = plot_edges(hx, hy, vis, 3.5, []);
h = plot_edges(hx, hy, vis, 12, col);
vis = getFaceVis(boxView{i}(3, :), faces);
ind = find(vis);
for j = 1 : length(ind)
   facepoints = boxView{i}(1:2, faces(ind(j), :))';
   plotface(facepoints, col)
end;
end;



function h = plot_edges(hx, hy, vis, lw, col)

if nargin < 5 | ~numel(col)
    %col = [1,0.5,0.5; [0.8,0.6,1]];
    %col = [1,0,0; [0.3,0.1,0.85]]; 
    %col = [1,0,0; [0.3,0.1,0.85]];
    col = [col; 0.6 * col];
    %col = [0,0,0; [0.2,0.2,0.2]];
else
    [u,v] = sort(col);
    f = ones(1, 3);
    f(v(2)) = 0.5;
    col = [col; col .* f];
end;

hold on;
edges = [1,2;2,3;3,4;4,1;1,5;2,6;5,6;4,8;3,7;6,7;5,8;7,8];
h = zeros(size(edges, 1), 1);
for i = 1 : size(edges, 1)
   x=[hx(edges(i, 1)); hx(edges(i, 2))];
   y=[hy(edges(i, 1)); hy(edges(i, 2))];
   if x> -600 & y>-600
   if vis(edges(i, 1)) & vis(edges(i, 2))
       h(i) = plot_col(x,y,lw,col(1,:),1); hold on;
   else
       h(i) = plot_col(x,y,lw,col(2,:),2); hold on;
   end;
   end;
end;

%for i = 1 : length(hx)
%    text(hx(i),hy(i)+5,sprintf('%d',i),'BackgroundColor',[0.5,0.5,1])
%end;
hold off


function h = plot_col(x,y,lw,col,line_style)

switch line_style
    case 1
        line_text = '-';
    otherwise
        line_text = '--';
        lw = lw - 1;
end;
if isfloat(col)
   h = plot(x,y,'LineWidth', lw, 'Color',col, 'LineStyle', line_text);
else
   h = plot(x,y,col,'LineWidth', lw, 'LineStyle', line_text); 
end;


function plotface(facepoints, col)

alpha = 0.15;
%col = [0, 1, 1; 1, 0., 0.3; 1,1,0; 0.3, 1, 0; 1,0,1; 0.3, 0, 1];
%n = length(facepoints) / 2;
%facepoints = reshape(facepoints, [2, n])';
patch(facepoints(:, 1),facepoints(:, 2), col, 'EdgeColor','k','linewidth', 2.8,'FaceAlpha', alpha,'AmbientStrength', 0, 'FaceLighting', 'flat', 'BackFaceLighting', 'lit');

function vis = getFaceVis(vertviz, faces)

vis = zeros(size(faces, 1), 1);
for i = 1 : size(faces, 1)
    viz_i = vertviz(faces(i, :));
    if sum(viz_i)==4
        vis(i) = 1;
    end;
end;